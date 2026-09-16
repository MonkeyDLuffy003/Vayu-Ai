import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'alarm_service.dart';

class AlarmStorageService {
  final SharedPreferences preferences;

  AlarmStorageService(this.preferences);

  // ============================================================
  // STORAGE KEY
  // ============================================================

  static const String _alarmsKey =
      'vayu_alarms';

  // ============================================================
  // SAVE ALARMS
  // ============================================================

  Future<void> saveAlarms(
    List<VayuAlarm> alarms,
  ) async {
    final encoded = jsonEncode(
      alarms
          .map(
            (alarm) => _alarmToJson(alarm),
          )
          .toList(),
    );

    await preferences.setString(
      _alarmsKey,
      encoded,
    );
  }

  // ============================================================
  // LOAD ALARMS
  // ============================================================

  Future<List<VayuAlarm>> getAlarms() async {
    final raw =
        preferences.getString(
      _alarmsKey,
    );

    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded =
          jsonDecode(raw);

      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) => _alarmFromJson(
              Map<String, dynamic>.from(
                item,
              ),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ============================================================
  // SAVE ONE ALARM
  // ============================================================

  Future<void> saveAlarm(
    VayuAlarm alarm,
  ) async {
    final alarms =
        await getAlarms();

    final index =
        alarms.indexWhere(
      (item) => item.id == alarm.id,
    );

    if (index >= 0) {
      alarms[index] = alarm;
    } else {
      alarms.add(alarm);
    }

    await saveAlarms(
      alarms,
    );
  }

  // ============================================================
  // DELETE ONE ALARM
  // ============================================================

  Future<void> deleteAlarm(
    String alarmId,
  ) async {
    final alarms =
        await getAlarms();

    alarms.removeWhere(
      (alarm) => alarm.id == alarmId,
    );

    await saveAlarms(
      alarms,
    );
  }

  // ============================================================
  // ENABLE / DISABLE
  // ============================================================

  Future<void> setAlarmEnabled(
    String alarmId,
    bool enabled,
  ) async {
    final alarms =
        await getAlarms();

    final index =
        alarms.indexWhere(
      (alarm) => alarm.id == alarmId,
    );

    if (index < 0) {
      return;
    }

    alarms[index] =
        alarms[index].copyWith(
      enabled: enabled,
    );

    await saveAlarms(
      alarms,
    );
  }

  // ============================================================
  // CLEAR ALL ALARMS
  // ============================================================

  Future<void> clearAllAlarms() async {
    await preferences.remove(
      _alarmsKey,
    );
  }

  // ============================================================
  // SERIALIZATION
  // ============================================================

  Map<String, dynamic> _alarmToJson(
    VayuAlarm alarm,
  ) {
    return {
      'id': alarm.id,
      'scheduledTime':
          alarm.scheduledTime.toIso8601String(),
      'label': alarm.label,
      'enabled': alarm.enabled,
    };
  }

  VayuAlarm _alarmFromJson(
    Map<String, dynamic> json,
  ) {
    return VayuAlarm(
      id: json['id'] as String? ?? '',
      scheduledTime:
          DateTime.tryParse(
                json['scheduledTime']
                        as String? ??
                    '',
              ) ??
              DateTime.now(),
      label: json['label'] as String?,
      enabled:
          json['enabled'] as bool? ?? true,
    );
  }
}
