package com.finext.asteria

import android.app.Activity
import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import io.flutter.FlutterInjector
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

/** Plays the packaged affirmation recording. */
class PracticeAudioBridge(private val activity: Activity, messenger: BinaryMessenger) {
    companion object {
        private const val ASSET = "assets/audio/practice-75.wav"
    }

    private val channel = MethodChannel(messenger, "asteria/practice-audio")
    private val audio = activity.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    private val assetKey = FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(ASSET)
    private val speech = AudioAttributes.Builder()
        .setUsage(AudioAttributes.USAGE_MEDIA)
        .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
        .build()
    private val onFocus = AudioManager.OnAudioFocusChangeListener { change ->
        if (change < 0) activity.runOnUiThread { pause() }
    }
    private val focusRequest = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
            .setAudioAttributes(speech)
            .setOnAudioFocusChangeListener(onFocus)
            .setWillPauseWhenDucked(true)
            .build()
    } else null

    private var player: MediaPlayer? = null
    private var session: Int? = null
    private var pendingSeek: Int? = null
    private var complete = false
    private var focused = false

    init {
        channel.setMethodCallHandler(::handle)
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        val owner = call.argument<Int>("session")
        try {
            when (call.method) {
                "load" -> {
                    releasePlayer()
                    val next = MediaPlayer()
                    try {
                        next.setAudioAttributes(speech)
                        setRecording(next)
                        next.prepare()
                    } catch (error: Exception) {
                        next.release()
                        throw error
                    }
                    next.setOnSeekCompleteListener {
                        val target = pendingSeek
                        if (target != null && kotlin.math.abs(it.currentPosition - target) < 250) {
                            pendingSeek = null
                        }
                    }
                    next.setOnCompletionListener {
                        pendingSeek = null
                        complete = true
                        abandonFocus()
                    }
                    session = owner
                    player = next
                }
                "close" -> {
                    if (session == owner) releasePlayer()
                    result.success(null)
                    return
                }
                else -> {
                    val current = player
                    if (session != owner || current == null) {
                        result.success(null)
                        return
                    }
                    when (call.method) {
                        "toggle" -> if (current.isPlaying) {
                            pause()
                        } else {
                            if (complete || (pendingSeek ?: current.currentPosition) >= current.duration) seek(current, 0)
                            if (!requestFocus()) throw IllegalStateException("Audio focus unavailable")
                            try {
                                current.start()
                            } catch (error: Exception) {
                                abandonFocus()
                                throw error
                            }
                        }
                        "pause" -> pause()
                        "seek" -> seek(current, call.argument<Int>("ms") ?: 0)
                        "loop" -> current.isLooping = call.argument<Boolean>("value") == true
                        "state" -> Unit
                        else -> { result.notImplemented(); return }
                    }
                }
            }
            val current = player ?: error("No player")
            result.success(mapOf(
                "position" to if (complete) current.duration else (pendingSeek ?: current.currentPosition),
                "duration" to current.duration,
                "playing" to current.isPlaying,
                "loop" to current.isLooping,
                "complete" to complete,
            ))
        } catch (error: Exception) {
            result.error("practice-audio", error.localizedMessage, null)
        }
    }

    private fun setRecording(next: MediaPlayer) {
        // AAPT stores WAV uncompressed by default. Support other packaging too.
        val descriptor = try { activity.assets.openFd(assetKey) } catch (_: java.io.FileNotFoundException) { null }
        if (descriptor != null) {
            descriptor.use { next.setDataSource(it.fileDescriptor, it.startOffset, it.length) }
            return
        }
        val cache = File.createTempFile("practice-", ".wav", activity.cacheDir)
        try {
            activity.assets.open(assetKey).use { source -> cache.outputStream().use { source.copyTo(it) } }
            next.setDataSource(cache.absolutePath)
        } finally {
            cache.delete()
        }
    }

    private fun seek(current: MediaPlayer, millis: Int) {
        val target = millis.coerceIn(0, current.duration)
        pendingSeek = target
        complete = target >= current.duration
        if (complete) pause()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            current.seekTo(target.toLong(), MediaPlayer.SEEK_CLOSEST)
        } else {
            @Suppress("DEPRECATION")
            current.seekTo(target)
        }
    }

    @Suppress("DEPRECATION")
    private fun requestFocus(): Boolean {
        if (focused) return true
        val status = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && focusRequest != null) {
            audio.requestAudioFocus(focusRequest)
        } else audio.requestAudioFocus(onFocus, AudioManager.STREAM_MUSIC, AudioManager.AUDIOFOCUS_GAIN)
        focused = status == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
        return focused
    }

    @Suppress("DEPRECATION")
    private fun abandonFocus() {
        if (!focused) return
        focused = false
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && focusRequest != null) {
            audio.abandonAudioFocusRequest(focusRequest)
        } else audio.abandonAudioFocus(onFocus)
    }

    private fun pause() {
        player?.takeIf { it.isPlaying }?.pause()
        abandonFocus()
    }

    private fun releasePlayer() {
        player?.setOnCompletionListener(null)
        player?.setOnSeekCompleteListener(null)
        pendingSeek = null
        player?.release()
        player = null
        complete = false
        session = null
        abandonFocus()
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
        releasePlayer()
    }
}
