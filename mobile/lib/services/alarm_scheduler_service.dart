import 'alarm_service.dart';
import 'notification_controller.dart';

class AlarmSchedulerService {
  final NotificationController _notificationController;

  AlarmSchedulerService({
    required NotificationController notificationController,
  }) : _notificationController =
            notificationController;

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> initialize() async {
    await _notificationController.initialize();
  }

  // ============================================================
  // SCHEDULE ALARM
  // ============================================================

  Future<bool> scheduleAlarm(
    VayuAlarm alarm,
  ) async {
    if (!alarm.enabled) {
      return false;
    }

    if (alarm.scheduledTime.isBefore(
      DateTime.now(),
    )) {
      return false;
    }

    // ==========================================================
    // ANDROID SCHEDULING HOOK
    // ==========================================================
    //
    // The actual Android alarm scheduling implementation will
    // be connected here.
    //
    // It will eventually:
    //
    // 1. Register the alarm with Android.
    // 2. Wake the application when required.
    // 3. Trigger Vayu's notification.
    // 4. Handle reboot restoration.
    //
    // We intentionally do not pretend that simply saving an
    // alarm schedules an Android system alarm.

    return true;
  }

  // ============================================================
  // CANCEL ALARM
  // ============================================================

  Future<void> cancelAlarm(
    VayuAlarm alarm,
  ) async {
    await _notificationController
        .cancelAlarmNotification(
      alarm.id.hashCode,
    );

    // Actual Android alarm cancellation will be
    // connected here.
  }

  // ============================================================
  // RESCHEDULE ALARM
  // ============================================================

  Future<bool> rescheduleAlarm(
    VayuAlarm alarm,
  ) async {
    await cancelAlarm(
      alarm,
    );

    return await scheduleAlarm(
      alarm,
    );
  }

  // ============================================================
  // TRIGGER ALARM NOTIFICATION
  // ============================================================

  Future<void> triggerAlarm(
    VayuAlarm alarm,
  ) async {
    if (!alarm.enabled) {
      return;
    }

    await _notificationController
        .showAlarm(
      alarmId: alarm.id.hashCode,
      label: alarm.label,
    );
  }

  // ============================================================
  // CANCEL ALL
  // ============================================================

  Future<void> cancelAll() async {
    await _notificationController
        .cancelAllNotifications();

    // Actual Android scheduled alarms will also
    // be cancelled here once the scheduler is connected.
  }
}
