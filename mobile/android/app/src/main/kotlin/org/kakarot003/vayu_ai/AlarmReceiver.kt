package org.kakarot003.vayu_ai

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class AlarmReceiver : BroadcastReceiver() {

    // ============================================================
    // RECEIVE ALARM
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

        showNotification(
            context = context,
            alarmId = alarmId,
            label = label
        )
    }

    // ============================================================
    // SHOW NOTIFICATION
    // ============================================================

    private fun showNotification(
        context: Context,
        alarmId: Int,
        label: String
    ) {
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
                .setAutoCancel(
                    true
                )
                .setOngoing(
                    false
                )
                .build()

        NotificationManagerCompat
            .from(context)
            .notify(
                alarmId,
                notification
            )
    }

    companion object {

        // ========================================================
        // INTENT DATA
        // ========================================================

        const val EXTRA_ALARM_ID =
            "vayu_alarm_id"

        const val EXTRA_ALARM_LABEL =
            "vayu_alarm_label"

        // ========================================================
        // NOTIFICATION CHANNEL
        // ========================================================

        const val CHANNEL_ID =
            "vayu_alarms"
    }
}
