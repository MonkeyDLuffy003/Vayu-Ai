import 'package:flutter/services.dart';

class AlarmManagerService {
  // ============================================================
  // METHOD CHANNEL
  // ============================================================

  static const MethodChannel _channel =
      MethodChannel('vayu_ai/alarm_manager');

  // ============================================================
  // CHECK EXACT ALARM ACCESS
  // ============================================================

  Future<bool> canScheduleExactAlarms() async {
    try {
      final result =
          await _channel.invokeMethod<bool>(
        'canScheduleExactAlarms',
      );

      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  // ============================================================
  // OPEN ANDROID EXACT ALARM SETTINGS
  // ============================================================

  Future<bool> openExactAlarmSettings() async {
    try {
      final result =
          await _channel.invokeMethod<bool>(
        'openExactAlarmSettings',
      );

      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  // ============================================================
  // SCHEDULE ALARM
  // ============================================================

  Future<bool> scheduleAlarm({
    required String alarmId,
    required DateTime scheduledTime,
    String label = 'Your Vayu alarm is ringing.',
  }) async {
    if (scheduledTime.isBefore(DateTime.now())) {
      return false;
    }

    try {
      final result =
          await _channel.invokeMethod<bool>(
        'scheduleAlarm',
        {
          'alarmId': alarmId,
          'triggerAtMillis':
              scheduledTime.millisecondsSinceEpoch,
          'label': label,
        },
      );

      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  // ============================================================
  // CANCEL ALARM
  // ============================================================

  Future<bool> cancelAlarm({
    required String alarmId,
  }) async {
    try {
      final result =
          await _channel.invokeMethod<bool>(
        'cancelAlarm',
        {
          'alarmId': alarmId,
        },
      );

      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  // ============================================================
  // RESCHEDULE ALARM
  // ============================================================

  Future<bool> rescheduleAlarm({
    required String alarmId,
    required DateTime scheduledTime,
    String label = 'Your Vayu alarm is ringing.',
  }) async {
    await cancelAlarm(
      alarmId: alarmId,
    );

    return scheduleAlarm(
      alarmId: alarmId,
      scheduledTime: scheduledTime,
      label: label,
    );
  }

  // ============================================================
  // OPEN APP SETTINGS
  // ============================================================

  Future<bool> openAppSettings() async {
    try {
      final result =
          await _channel.invokeMethod<bool>(
        'openAppSettings',
      );

      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}
