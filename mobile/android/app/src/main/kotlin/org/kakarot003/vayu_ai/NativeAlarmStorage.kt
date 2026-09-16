package org.kakarot003.vayu_ai

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

class NativeAlarmStorage(
    context: Context
) {

    // ============================================================
    // STORAGE
    // ============================================================

    private val preferences =
        context.getSharedPreferences(
            PREFS_NAME,
            Context.MODE_PRIVATE
        )

    // ============================================================
    // SAVE ALARM
    // ============================================================

    fun saveAlarm(
        alarmId: String,
        triggerAtMillis: Long,
        label: String
    ) {

        val alarms = getAlarms().toMutableList()

        alarms.removeAll {
            it.alarmId == alarmId
        }

        alarms.add(
            NativeAlarm(
                alarmId = alarmId,
                triggerAtMillis = triggerAtMillis,
                label = label
            )
        )

        saveAll(alarms)
    }

    // ============================================================
    // DELETE ALARM
    // ============================================================

    fun deleteAlarm(
        alarmId: String
    ) {

        val alarms =
            getAlarms()
                .filter {
                    it.alarmId != alarmId
                }

        saveAll(alarms)
    }

    // ============================================================
    // GET ALL ALARMS
    // ============================================================

    fun getAlarms(): List<NativeAlarm> {

        val raw =
            preferences.getString(
                ALARMS_KEY,
                null
            ) ?: return emptyList()

        return try {

            val array =
                JSONArray(raw)

            val alarms =
                mutableListOf<NativeAlarm>()

            for (index in 0 until array.length()) {

                val item =
                    array.getJSONObject(index)

                alarms.add(
                    NativeAlarm(
                        alarmId =
                            item.getString(
                                "alarmId"
                            ),
                        triggerAtMillis =
                            item.getLong(
                                "triggerAtMillis"
                            ),
                        label =
                            item.optString(
                                "label",
                                "Your Vayu alarm is ringing."
                            )
                    )
                )
            }

            alarms

        } catch (
            exception: Exception
        ) {
            emptyList()
        }
    }

    // ============================================================
    // REMOVE EXPIRED ALARMS
    // ============================================================

    fun removeExpiredAlarms() {

        val currentTime =
            System.currentTimeMillis()

        val futureAlarms =
            getAlarms()
                .filter {
                    it.triggerAtMillis > currentTime
                }

        saveAll(futureAlarms)
    }

    // ============================================================
    // CLEAR ALL
    // ============================================================

    fun clearAll() {

        preferences
            .edit()
            .remove(ALARMS_KEY)
            .apply()
    }

    // ============================================================
    // SAVE ALL
    // ============================================================

    private fun saveAll(
        alarms: List<NativeAlarm>
    ) {

        val array = JSONArray()

        alarms.forEach { alarm ->

            val objectData =
                JSONObject().apply {

                    put(
                        "alarmId",
                        alarm.alarmId
                    )

                    put(
                        "triggerAtMillis",
                        alarm.triggerAtMillis
                    )

                    put(
                        "label",
                        alarm.label
                    )
                }

            array.put(objectData)
        }

        preferences
            .edit()
            .putString(
                ALARMS_KEY,
                array.toString()
            )
            .apply()
    }

    // ============================================================
    // CONSTANTS
    // ============================================================

    companion object {

        private const val PREFS_NAME =
            "vayu_native_alarm_storage"

        private const val ALARMS_KEY =
            "scheduled_alarms"
    }
}

// ================================================================
// NATIVE ALARM MODEL
// ================================================================

data class NativeAlarm(
    val alarmId: String,
    val triggerAtMillis: Long,
    val label: String
)
