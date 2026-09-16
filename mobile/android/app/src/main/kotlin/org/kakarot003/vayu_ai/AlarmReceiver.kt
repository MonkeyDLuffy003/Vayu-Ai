package org.kakarot003.vayu_ai

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class AlarmReceiver : BroadcastReceiver() {

    // ============================================================
    // ALARM RECEIVED
    // ============================================================

    override fun onReceive(
        context: Context,
        intent: Intent
    ) {

        val alarmId =
            intent.getIntExtra(
                EXTRA_ALARM_ID,
                0
            )

        val label =
            intent.getStringExtra(
                EXTRA_ALARM_LABEL
            ) ?: "Your Vayu alarm is ringing."

        // ========================================================
        // CREATE CHANNEL
        // ========================================================

        createNotificationChannel(context)

        // ========================================================
        // SHOW ALARM
        // ========================================================

        showNotification(
            context = context,
            alarmId = alarmId,
            label = label
        )
    }

    // ============================================================
    // CREATE NOTIFICATION CHANNEL
    // ============================================================

    private fun createNotificationChannel(
        context: Context
    ) {

        if (
            Build.VERSION.SDK_INT >=
            Build.VERSION_CODES.O
        ) {

            val channel =
                NotificationChannel(
                    CHANNEL_ID,
                    "Vayu Alarms",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {

                    description =
                        "Alarm notifications from Vayu AI"

                    enableVibration(true)

                    setShowBadge(true)
                }

            val notificationManager =
                context.getSystemService(
                    Context.NOTIFICATION_SERVICE
                ) as NotificationManager

            notificationManager.createNotificationChannel(
                channel
            )
        }
    }

    // ============================================================
    // SHOW NOTIFICATION
    // ============================================================

    private fun showNotification(
        context: Context,
        alarmId: Int,
        label: String
    ) {

        // Android 13+ requires notification permission.
        if (
            Build.VERSION.SDK_INT >=
            Build.VERSION_CODES.TIRAMISU
        ) {

            if (
                context.checkSelfPermission(
                    Manifest.permission.POST_NOTIFICATIONS
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                return
            }
        }

        val notification =
            NotificationCompat.Builder(
                context,
                CHANNEL_ID
            )
                .setSmallIcon(
                    android.R.drawable.ic_lock_idle_alarm
                )
                .setContentTitle(
                    "Vayu Alarm"
                )
                .setContentText(
                    label
                )
                .setPriority(
                    NotificationCompat.PRIORITY_MAX
                )
                .setCategory(
                    NotificationCompat.CATEGORY_ALARM
                )
                .setAutoCancel(true)
                .setOngoing(false)
                .setVibrate(
                    longArrayOf(
                        0,
                        500,
                        300,
                        500,
                        300,
                        800
                    )
                )
                .build()

        NotificationManagerCompat
            .from(context)
            .notify(
                alarmId,
                notification
            )
    }

    // ============================================================
    // CONSTANTS
    // ============================================================

    companion object {

        const val EXTRA_ALARM_ID =
            "vayu_alarm_id"

        const val EXTRA_ALARM_LABEL =
            "vayu_alarm_label"

        const val CHANNEL_ID =
            "vayu_alarms"
    }
}
