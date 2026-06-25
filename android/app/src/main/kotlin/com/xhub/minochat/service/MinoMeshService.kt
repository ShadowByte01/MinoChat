package com.xhub.minochat.service

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
 * Foreground service that keeps the BLE / Nearby Connections mesh alive
 * even when the app goes to background — essential for offline chat &
 * file transfer to actually be reliable.
 *
 * Foreground type: dataSync (Android 14+).
 */
class MinoMeshService : Service() {

    companion object {
        const val CH_ID = "mino_mesh"
        const val CH_NAME = "Offline Mesh"
        const val NOTIF_ID = 4343

        fun start(ctx: Context) {
            val i = Intent(ctx, MinoMeshService::class.java)
            androidx.core.content.ContextCompat.startForegroundService(ctx, i)
        }
        fun stop(ctx: Context) {
            ctx.stopService(Intent(ctx, MinoMeshService::class.java))
        }
    }

    override fun onCreate() {
        super.onCreate()
        ensureChannel()
        val n = buildNotification("Offline mesh active — you can chat without internet")
        if (Build.VERSION.SDK_INT >= 34) {
            startForeground(NOTIF_ID, n, ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC)
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
                description = "Mino Chat offline mesh"
                setShowBadge(false)
            }
            nm.createNotificationChannel(ch)
        }
    }

    private fun buildNotification(text: String): Notification =
        NotificationCompat.Builder(this, CH_ID)
            .setContentTitle("Mino Chat · Offline")
            .setContentText(text)
            .setSmallIcon(android.R.drawable.stat_sys_data_bluetooth)
            .setOngoing(true)
            .setSilent(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
}
