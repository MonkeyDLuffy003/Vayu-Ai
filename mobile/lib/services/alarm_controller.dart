import 'alarm_service.dart';
import 'alarm_storage_service.dart';

class AlarmController {
  final AlarmService _alarmService;
  final AlarmStorageService _storage;

  AlarmController({
    required AlarmService alarmService,
    required AlarmStorageService storage,
  })  : _alarmService = alarmService,
        _storage = storage;

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> initialize() async {
    final storedAlarms =
        await _storage.getAlarms();

    _alarmService.clearAllAlarms();

    for (final alarm in storedAlarms) {
      if (alarm.scheduledTime.isAfter(
        DateTime.now(),
      )) {
        _alarmService.restoreAlarm(
          alarm,
        );
      }
    }
  }

  // ============================================================
  // GET ALARMS
  // ============================================================

  List<VayuAlarm> getAlarms() {
    return _alarmService.getAlarms();
  }

  // ============================================================
  // SET ALARM
  // ============================================================

  Future<VayuAlarm> setAlarm({
    required DateTime scheduledTime,
    String? label,
  }) async {
    final alarm =
        _alarmService.setAlarm(
      scheduledTime: scheduledTime,
      label: label,
    );

    await _storage.saveAlarm(
      alarm,
    );

    return alarm;
  }

  // ============================================================
  // CANCEL ALARM
  // ============================================================

  Future<bool> cancelAlarm(
    String alarmId,
  ) async {
    final cancelled =
        _alarmService.cancelAlarm(
      alarmId,
    );

    if (cancelled) {
      await _storage.deleteAlarm(
        alarmId,
      );
    }

    return cancelled;
  }

  // ============================================================
  // ENABLE / DISABLE
  // ============================================================

  Future<bool> setEnabled(
    String alarmId,
    bool enabled,
  ) async {
    final changed =
        _alarmService.setAlarmEnabled(
      alarmId,
      enabled,
    );

    if (changed) {
      await _storage.setAlarmEnabled(
        alarmId,
        enabled,
      );
    }

    return changed;
  }

  // ============================================================
  // TOGGLE ALARM
  // ============================================================

  Future<bool> toggleAlarm(
    String alarmId,
  ) async {
    final alarm =
        _alarmService.getAlarm(
      alarmId,
    );

    if (alarm == null) {
      return false;
    }

    return setEnabled(
      alarmId,
      !alarm.enabled,
    );
  }

  // ============================================================
  // NEXT ALARM
  // ============================================================

  VayuAlarm? getNextAlarm() {
    return _alarmService.getNextAlarm();
  }

  // ============================================================
  // DELETE ALL
  // ============================================================

  Future<void> clearAllAlarms() async {
    _alarmService.clearAllAlarms();

    await _storage.clearAllAlarms();
  }
}
