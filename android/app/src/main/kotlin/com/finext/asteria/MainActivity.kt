package com.finext.asteria

import android.os.Build
import com.google.android.gms.ads.identifier.AdvertisingIdClient
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var practiceAudio: PracticeAudioBridge? = null

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        practiceAudio?.dispose()
        practiceAudio = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        practiceAudio = PracticeAudioBridge(this, flutterEngine.dartExecutor.binaryMessenger)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "asteria/analytics-device")
            .setMethodCallHandler { call, result ->
                if (call.method != "read") {
                    result.notImplemented()
                } else {
                    val app = applicationContext
                    Thread {
                        val context = mutableMapOf<String, Any>("os" to Build.VERSION.RELEASE)
                        try {
                            val info = AdvertisingIdClient.getAdvertisingIdInfo(app)
                            context["aie"] = !info.isLimitAdTrackingEnabled
                            val id = info.id
                            if (!info.isLimitAdTrackingEnabled && !id.isNullOrBlank() &&
                                id != "00000000-0000-0000-0000-000000000000") {
                                context["advertising_id"] = id
                            }
                        } catch (_: Exception) {
                            // No Play services or unavailable ID: never reuse a cached identifier.
                            context["aie"] = false
                        }
                        runOnUiThread { result.success(context) }
                    }.start()
                }
            }
    }
}
