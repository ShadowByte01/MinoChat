package com.xhub.minochat

import android.os.Bundle
import android.os.PersistableBundle
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Single-activity host for Mino Chat.
 *
 * Responsibilities:
 *  - Installs Android 12+ SplashScreen API.
 *  - Exposes tiny MethodChannels to Flutter for things that need native code:
 *      * mino/device      → battery optimizations, exact-alarm permission, package info
 *      * mino/foreground   → start / stop our voice + mesh foreground services
 *  - Keeps the rest of the app pure Dart via plugins.
 *
 * Made by Lost Weeds (Abhinit) · X Hub
 */
class MainActivity : FlutterActivity() {

    private val DEVICE_CH = "mino/device"
    private val FG_CH = "mino/foreground"

    override fun onCreate(savedInstanceState: Bundle?) {
        // Splash must install before super.onCreate
        installSplashScreen()
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DEVICE_CH)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "appVersion" -> result.success(packageInfo()?.versionName ?: "0.0.0")
                    "buildNumber" -> result.success(packageInfo()?.versionCode?.toString() ?: "0")
                    "packageName" -> result.success(packageName)
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FG_CH)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startVoice" -> {
                        val intent = android.content.Intent(this, com.xhub.minochat.voice.MinoVoiceService::class.java)
                        androidx.core.content.ContextCompat.startForegroundService(this, intent)
                        result.success(true)
                    }
                    "stopVoice" -> {
                        stopService(android.content.Intent(this, com.xhub.minochat.voice.MinoVoiceService::class.java))
                        result.success(true)
                    }
                    "startMesh" -> {
                        val intent = android.content.Intent(this, com.xhub.minochat.service.MinoMeshService::class.java)
                        androidx.core.content.ContextCompat.startForegroundService(this, intent)
                        result.success(true)
                    }
                    "stopMesh" -> {
                        stopService(android.content.Intent(this, com.xhub.minochat.service.MinoMeshService::class.java))
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun packageInfo() =
        try {
            if (android.os.Build.VERSION.SDK_INT >= 33)
                packageManager.getPackageInfo(packageName, android.content.pm.PackageManager.PackageInfoFlags.of(0))
            else
                @Suppress("DEPRECATION") packageManager.getPackageInfo(packageName, 0)
        } catch (e: Exception) { null }
}
