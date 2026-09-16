package org.kakarot003.vayu_ai

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

class BootReceiver : BroadcastReceiver() {

    // ============================================================
    // DEVICE BOOT COMPLETED
    // ============================================================

    override fun onReceive(
        context: Context,
        intent: Intent
    ) {

        if (
            intent.action !=
            Intent.ACTION_BOOT_COMPLETED
        ) {
            return
        }

        restoreAlarms(context)
    }

    // ============================================================
    // RESTORE STORED ALARMS
    // ============================================================

    private fun restoreAlarms(
        context: Context
    ) {

        /*
         * Alarm persistence will be connected in the next step.
         *
         * The receiver is intentionally kept lightweight.
         * Android may execute BroadcastReceiver only for a
         * limited amount of time after boot.
         *
         * Do not perform heavy Flutter initialization here.
         */

        if (
            Build.VERSION.SDK_INT >=
            Build.VERSION_CODES.S
        ) {

            val alarmManager =
                context.getSystemService(
                    Context.ALARM_SERVICE
                ) as AlarmManager

            if (
                !alarmManager.canScheduleExactAlarms()
            ) {
                return
            }
        }

        // ========================================================
        // ALARM RESTORATION HOOK
        // ========================================================
        //
        // The actual stored-alarm restoration will be connected
        // after native alarm persistence is added.
        //
        // ========================================================
    }
}
