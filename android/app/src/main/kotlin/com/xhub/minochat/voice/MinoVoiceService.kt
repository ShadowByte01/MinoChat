package com.xhub.minochat.voice

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

/**
 * Foreground service that keeps the mic + media session alive while the user
 * records a long voice note OR is inside a Live audio room.
 *
 * Foreground type: microphone | mediaPlayback (Android 14+ requires explicit type).
 */
class MinoVoiceService : Service() {

    companion object {
        const val CH_ID = "mino_voice"
        const val CH_NAME = "Voice & Live"
        const val NOTIF_ID = 4242

        fun start(ctx: Context) {
            val i = Intent(ctx, MinoVoiceService::class.java)
            androidx.core.content.ContextCompat.startForegroundService(ctx, i)
        }

        fun stop(ctx: Context) {
            ctx.stopService(Intent(ctx, MinoVoiceService::class.java))
        }
    }

    override fun onCreate() {
        super.onCreate()
        ensureChannel()
        val n = buildNotification("Mino Chat is recording / live")
        if (Build.VERSION.SDK_INT >= 34) {
            startForeground(NOTIF_ID, n, ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE or ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK)
        } else {
            startForeground(NOTIF_ID, n)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int = START_STICKY

    override fun onBind(intent: Intent?): IBinder? = null

    private fun ensureChannel() {
        val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= 26 && nm.getNotificationChannel(CH_ID) == null) {
            val ch = NotificationChannel(CH_ID, CH_NAME, NotificationManager.IMPORTANCE_LOW).apply {
                description = "Keeps Mino Chat voice / live alive"
                setShowBadge(false)
            }
            nm.createNotificationChannel(ch)
        }
    }

    private fun buildNotification(text: String): Notification =
        NotificationCompat.Builder(this, CH_ID)
            .setContentTitle("Mino Chat")
            .setContentText(text)
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setOngoing(true)
            .setSilent(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
}
