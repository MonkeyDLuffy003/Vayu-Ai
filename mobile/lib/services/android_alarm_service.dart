import 'dart:io';

import 'alarm_service.dart';
import 'alarm_scheduler_service.dart';

class AndroidAlarmService {
  final AlarmSchedulerService _scheduler;

  AndroidAlarmService({
    required AlarmSchedulerService scheduler,
  }) : _scheduler = scheduler;

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> initialize() async {
    if (!Platform.isAndroid) {
      return;
    }

    await _scheduler.initialize();
  }

  // ============================================================
  // SCHEDULE
  // ============================================================

  Future<bool> schedule(
    VayuAlarm alarm,
  ) async {
    if (!Platform.isAndroid) {
      return false;
    }

    return await _scheduler.scheduleAlarm(
      alarm,
    );
  }

  // ============================================================
  // CANCEL
  // ============================================================

  Future<void> cancel(
    VayuAlarm alarm,
  ) async {
    if (!Platform.isAndroid) {
      return;
    }

    await _scheduler.cancelAlarm(
      alarm,
    );
  }

  // ============================================================
  // RESCHEDULE
  // ============================================================

  Future<bool> reschedule(
    VayuAlarm alarm,
  ) async {
    if (!Platform.isAndroid) {
      return false;
    }

    return await _scheduler.rescheduleAlarm(
      alarm,
    );
  }

  // ============================================================
  // TRIGGER
  // ============================================================

  Future<void> trigger(
    VayuAlarm alarm,
  ) async {
    if (!Platform.isAndroid) {
      return;
    }

    await _scheduler.triggerAlarm(
      alarm,
    );
  }

  // ============================================================
  // CANCEL ALL
  // ============================================================

  Future<void> cancelAll() async {
    if (!Platform.isAndroid) {
      return;
    }

    await _scheduler.cancelAll();
  }
}
