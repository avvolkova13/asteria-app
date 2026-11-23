package com.finext.asteria

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

internal class DictationBridge(
    private val activity: Activity,
    messenger: BinaryMessenger,
) {
    companion object {
        const val MICROPHONE_REQUEST = 51917
        private const val MAX_LISTENING_MS = 60_000L
        private const val FINAL_RESULT_TIMEOUT_MS = 3_000L
    }

    private class Session(
        val id: String,
        val locale: String,
        val reply: MethodChannel.Result,
    ) {
        var recognizer: SpeechRecognizer? = null
        var bestPartial: String? = null
        var timeout: Runnable? = null
        var stopping = false
    }

    private val main = Handler(Looper.getMainLooper())
    private val channel = MethodChannel(messenger, "asteria/dictation")
    private var active: Session? = null
    private var permissionSession: Session? = null

    init {
        channel.setMethodCallHandler(::handle)
    }

    private fun handle(call: MethodCall, reply: MethodChannel.Result) {
        val id = call.argument<String>("id")
        when (call.method) {
            "start" -> {
                val locale = call.argument<String>("locale")
                if (id.isNullOrBlank() || locale.isNullOrBlank()) {
                    reply.error("unavailable", null, null)
                    return
                }
                start(Session(id, locale, reply))
            }
            "stop", "cancel" -> {
                active?.takeIf { it.id == id }?.let { session ->
                    if (call.method == "stop") stop(session) else finish(session)
                }
                reply.success(null)
            }
            else -> reply.notImplemented()
        }
    }

    private fun start(session: Session) {
        if (active != null || permissionSession != null) {
            session.reply.error("busy", null, null)
            return
        }
        if (!SpeechRecognizer.isRecognitionAvailable(activity)) {
            session.reply.error("unavailable", null, null)
            return
        }
        active = session
        if (activity.checkSelfPermission(Manifest.permission.RECORD_AUDIO) ==
            PackageManager.PERMISSION_GRANTED
        ) {
            listen(session)
        } else {
            permissionSession = session
            try {
                activity.requestPermissions(
                    arrayOf(Manifest.permission.RECORD_AUDIO),
                    MICROPHONE_REQUEST,
                )
            } catch (_: RuntimeException) {
                permissionSession = null
                finish(session, error = "unavailable")
            }
        }
    }

    fun onMicrophonePermission(grantResults: IntArray) {
        val session = permissionSession ?: return
        permissionSession = null
        if (active !== session) return
        if (grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED) {
            listen(session)
        } else {
            finish(session, error = "permission_denied")
        }
    }

    private fun listen(session: Session) {
        try {
            val recognizer = SpeechRecognizer.createSpeechRecognizer(activity)
            session.recognizer = recognizer
            recognizer.setRecognitionListener(object : RecognitionListener {
                override fun onReadyForSpeech(params: Bundle?) = Unit
                override fun onBeginningOfSpeech() = Unit
                override fun onRmsChanged(rmsdB: Float) = Unit
                override fun onBufferReceived(buffer: ByteArray?) = Unit
                override fun onEvent(eventType: Int, params: Bundle?) = Unit

                override fun onEndOfSpeech() {
                    if (active !== session) return
                    session.stopping = true
                    awaitFinalResult(session)
                }

                override fun onPartialResults(partialResults: Bundle?) {
                    if (active !== session) return
                    transcript(partialResults)?.let { session.bestPartial = it }
                }

                override fun onResults(results: Bundle?) {
                    val best = transcript(results) ?: session.bestPartial
                    if (best == null) finish(session, error = "no_speech")
                    else finish(session, text = best)
                }

                override fun onError(error: Int) {
                    if (error == SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS) {
                        finish(session, error = "permission_denied")
                        return
                    }
                    if (session.bestPartial != null) {
                        finish(session, text = session.bestPartial)
                        return
                    }
                    finish(session, error = when (error) {
                        SpeechRecognizer.ERROR_NO_MATCH,
                        SpeechRecognizer.ERROR_SPEECH_TIMEOUT -> "no_speech"
                        SpeechRecognizer.ERROR_RECOGNIZER_BUSY -> "busy"
                        else -> "unavailable"
                    })
                }
            })
            setTimeout(session, MAX_LISTENING_MS) { stop(session) }
            recognizer.startListening(
                Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH)
                    .putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
                    .putExtra(RecognizerIntent.EXTRA_LANGUAGE, session.locale)
                    .putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
                    .putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1),
            )
        } catch (_: SecurityException) {
            finish(session, error = "permission_denied")
        } catch (_: RuntimeException) {
            finish(session, error = "unavailable")
        }
    }

    private fun transcript(results: Bundle?): String? =
        results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
            ?.firstOrNull()?.trim()?.takeIf { it.isNotEmpty() }

    private fun stop(session: Session) {
        if (active !== session || session.stopping) return
        val recognizer = session.recognizer
        if (recognizer == null) {
            finish(session)
            return
        }
        session.stopping = true
        awaitFinalResult(session)
        try {
            recognizer.stopListening()
        } catch (_: RuntimeException) {
            val best = session.bestPartial
            if (best == null) finish(session, error = "unavailable")
            else finish(session, text = best)
        }
    }

    private fun awaitFinalResult(session: Session) {
        setTimeout(session, FINAL_RESULT_TIMEOUT_MS) {
            val best = session.bestPartial
            if (best == null) finish(session, error = "no_speech")
            else finish(session, text = best)
        }
    }

    private fun setTimeout(session: Session, delay: Long, action: () -> Unit) {
        session.timeout?.let(main::removeCallbacks)
        session.timeout = Runnable {
            if (active === session) action()
        }.also { main.postDelayed(it, delay) }
    }

    private fun finish(session: Session, text: String? = null, error: String? = null) {
        if (active !== session) return
        active = null
        session.timeout?.let(main::removeCallbacks)
        session.recognizer?.let { recognizer ->
            runCatching { recognizer.cancel() }
            runCatching { recognizer.destroy() }
        }
        if (error == null) session.reply.success(text)
        else session.reply.error(error, null, null)
    }

    fun cancel() {
        active?.let { finish(it) }
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
        cancel()
        permissionSession = null
    }
}
