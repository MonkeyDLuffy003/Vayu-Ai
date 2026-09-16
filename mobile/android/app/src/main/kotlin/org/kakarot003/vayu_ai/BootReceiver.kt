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

        // ========================================================
        // CHECK EXACT ALARM ACCESS
        // ========================================================

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
        // LOAD NATIVE ALARMS
        // ========================================================

        val storage =
            NativeAlarmStorage(context)

        val alarms =
            storage.getAlarms()

        val currentTime =
            System.currentTimeMillis()

        // ========================================================
        // RESTORE FUTURE ALARMS
        // ========================================================

        alarms.forEach { alarm ->

            if (
                alarm.triggerAtMillis <=
                currentTime
            ) {
                return@forEach
            }

            scheduleAlarm(
                context = context,
                alarm = alarm
            )
        }

        // ========================================================
        // REMOVE EXPIRED ALARMS
        // ========================================================

        storage.removeExpiredAlarms()
    }

    // ============================================================
    // SCHEDULE RESTORED ALARM
    // ============================================================

    private fun scheduleAlarm(
        context: Context,
        alarm: NativeAlarm
    ) {

        try {

            val alarmManager =
                context.getSystemService(
                    Context.ALARM_SERVICE
                ) as AlarmManager

            val notificationId =
                stableNotificationId(
                    alarm.alarmId
                )

            val intent =
                Intent(
                    context,
                    AlarmReceiver::class.java
                ).apply {

                    putExtra(
                        AlarmReceiver.EXTRA_ALARM_ID,
                        notificationId
                    )

                    putExtra(
                        AlarmReceiver.EXTRA_ALARM_LABEL,
                        alarm.label
                    )
                }

            val pendingIntent =
                PendingIntent.getBroadcast(
                    context,
                    notificationId,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or
                            PendingIntent.FLAG_IMMUTABLE
                )

            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                alarm.triggerAtMillis,
                pendingIntent
            )

        } catch (
            exception: SecurityException
        ) {

            // Exact alarm access was removed.
            return

        } catch (
            exception: Exception
        ) {

            // Prevent boot receiver from crashing Android.
            return
        }
    }

    // ============================================================
    // STABLE INTEGER ID
    // ============================================================

    private fun stableNotificationId(
        value: String
    ): Int {

        var hash = 0

        for (character in value) {

            hash =
                31 * hash +
                        character.code
        }

        return hash and 0x7fffffff
    }
}
