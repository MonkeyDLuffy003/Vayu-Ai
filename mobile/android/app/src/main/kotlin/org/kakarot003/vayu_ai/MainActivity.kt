package org.kakarot003.vayu_ai

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    // ============================================================
    // METHOD CHANNEL
    // ============================================================

    private val CHANNEL =
        "vayu_ai/alarm_manager"

    // ============================================================
    // NATIVE ALARM STORAGE
    // ============================================================

    private lateinit var alarmStorage:
        NativeAlarmStorage

    // ============================================================
    // FLUTTER → ANDROID BRIDGE
    // ============================================================

    override fun configureFlutterEngine(
        @NonNull flutterEngine: FlutterEngine
    ) {

        super.configureFlutterEngine(
            flutterEngine
        )

        alarmStorage =
            NativeAlarmStorage(this)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                // ==================================================
                // CHECK EXACT ALARM ACCESS
                // ==================================================

                "canScheduleExactAlarms" -> {

                    result.success(
                        canScheduleExactAlarms()
                    )
                }

                // ==================================================
                // OPEN EXACT ALARM SETTINGS
                // ==================================================

                "openExactAlarmSettings" -> {

                    result.success(
                        openExactAlarmSettings()
                    )
                }

                // ==================================================
                // SCHEDULE ALARM
                // ==================================================

                "scheduleAlarm" -> {

                    val alarmId =
                        call.argument<String>(
                            "alarmId"
                        )

                    val triggerAtMillis =
                        call.argument<Long>(
                            "triggerAtMillis"
                        )

                    val label =
                        call.argument<String>(
                            "label"
                        )
                            ?: "Your Vayu alarm is ringing."

                    if (
                        alarmId == null ||
                        triggerAtMillis == null
                    ) {

                        result.error(
                            "INVALID_ARGUMENTS",
                            "alarmId and triggerAtMillis are required.",
                            null
                        )

                        return@setMethodCallHandler
                    }

                    val success =
                        scheduleAlarm(
                            alarmId,
                            triggerAtMillis,
                            label
                        )

                    result.success(success)
                }

                // ==================================================
                // CANCEL ALARM
                // ==================================================

                "cancelAlarm" -> {

                    val alarmId =
                        call.argument<String>(
                            "alarmId"
                        )

                    if (alarmId == null) {

                        result.error(
                            "INVALID_ARGUMENTS",
                            "alarmId is required.",
                            null
                        )

                        return@setMethodCallHandler
                    }

                    result.success(
                        cancelAlarm(alarmId)
                    )
                }

                // ==================================================
                // OPEN APP SETTINGS
                // ==================================================

                "openAppSettings" -> {

                    result.success(
                        openAppSettings()
                    )
                }

                // ==================================================
                // UNKNOWN METHOD
                // ==================================================

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    // ============================================================
    // EXACT ALARM PERMISSION
    // ============================================================

    private fun canScheduleExactAlarms():
        Boolean {

        if (
            Build.VERSION.SDK_INT <
            Build.VERSION_CODES.S
        ) {
            return true
        }

        val alarmManager =
            getSystemService(
                Context.ALARM_SERVICE
            ) as AlarmManager

        return alarmManager
            .canScheduleExactAlarms()
    }

    // ============================================================
    // OPEN EXACT ALARM SETTINGS
    // ============================================================

    private fun openExactAlarmSettings():
        Boolean {

        return try {

            if (
                Build.VERSION.SDK_INT >=
                Build.VERSION_CODES.S
            ) {

                val intent =
                    Intent(
                        Settings
                            .ACTION_REQUEST_SCHEDULE_EXACT_ALARM
                    )

                intent.data =
                    android.net.Uri.parse(
                        "package:$packageName"
                    )

                startActivity(intent)

            } else {

                val intent =
                    Intent(
                        Settings
                            .ACTION_APPLICATION_DETAILS_SETTINGS
                    )

                intent.data =
                    android.net.Uri.parse(
                        "package:$packageName"
                    )

                startActivity(intent)
            }

            true

        } catch (
            exception: Exception
        ) {

            false
        }
    }

    // ============================================================
    // SCHEDULE ALARM
    // ============================================================

    private fun scheduleAlarm(
        alarmId: String,
        triggerAtMillis: Long,
        label: String
    ): Boolean {

        return try {

            if (
                Build.VERSION.SDK_INT >=
                Build.VERSION_CODES.S &&
                !canScheduleExactAlarms()
            ) {
                return false
            }

            if (
                triggerAtMillis <=
                System.currentTimeMillis()
            ) {
                return false
            }

            val alarmManager =
                getSystemService(
                    Context.ALARM_SERVICE
                ) as AlarmManager

            val notificationId =
                stableNotificationId(
                    alarmId
                )

            val intent =
                Intent(
                    this,
                    AlarmReceiver::class.java
                ).apply {

                    putExtra(
                        AlarmReceiver.EXTRA_ALARM_ID,
                        notificationId
                    )

                    putExtra(
                        AlarmReceiver.EXTRA_ALARM_LABEL,
                        label
                    )
                }

            val pendingIntent =
                PendingIntent.getBroadcast(
                    this,
                    notificationId,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or
                            PendingIntent.FLAG_IMMUTABLE
                )

            // ====================================================
            // ANDROID EXACT ALARM
            // ====================================================

            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                triggerAtMillis,
                pendingIntent
            )

            // ====================================================
            // SAVE NATIVE BACKUP
            // ====================================================

            alarmStorage.saveAlarm(
                alarmId = alarmId,
                triggerAtMillis = triggerAtMillis,
                label = label
            )

            true

        } catch (
            exception: SecurityException
        ) {

            false

        } catch (
            exception: Exception
        ) {

            false
        }
    }

    // ============================================================
    // CANCEL ALARM
    // ============================================================

    private fun cancelAlarm(
        alarmId: String
    ): Boolean {

        return try {

            val alarmManager =
                getSystemService(
                    Context.ALARM_SERVICE
                ) as AlarmManager

            val notificationId =
                stableNotificationId(
                    alarmId
                )

            val intent =
                Intent(
                    this,
                    AlarmReceiver::class.java
                )

            val pendingIntent =
                PendingIntent.getBroadcast(
                    this,
                    notificationId,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or
                            PendingIntent.FLAG_IMMUTABLE
                )

            alarmManager.cancel(
                pendingIntent
            )

            pendingIntent.cancel()

            // ====================================================
            // REMOVE NATIVE BACKUP
            // ====================================================

            alarmStorage.deleteAlarm(
                alarmId
            )

            true

        } catch (
            exception: Exception
        ) {

            false
        }
    }

    // ============================================================
    // OPEN APP SETTINGS
    // ============================================================

    private fun openAppSettings():
        Boolean {

        return try {

            val intent =
                Intent(
                    Settings
                        .ACTION_APPLICATION_DETAILS_SETTINGS
                )

            intent.data =
                android.net.Uri.parse(
                    "package:$packageName"
                )

            startActivity(intent)

            true

        } catch (
            exception: Exception
        ) {

            false
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
