import 'alarm_manager_service.dart';
import 'alarm_service.dart';
import 'notification_controller.dart';

class AlarmSchedulerService {
  // ============================================================
  // DEPENDENCIES
  // ============================================================

  final AlarmManagerService alarmManagerService;
  final NotificationController notificationController;
  final AlarmService alarmService;

  AlarmSchedulerService({
    required this.alarmManagerService,
    required this.notificationController,
    required this.alarmService,
  });

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> initialize() async {
    // The Android side restores alarms after reboot.
    //
    // Here we only make sure the notification system is ready.
    await notificationController.initialize();
  }

  // ============================================================
  // CHECK EXACT ALARM ACCESS
  // ============================================================

  Future<bool> canScheduleExactAlarms() async {
    return alarmManagerService
        .canScheduleExactAlarms();
  }

  // ============================================================
  // REQUEST EXACT ALARM ACCESS
  // ============================================================

  Future<bool> requestExactAlarmAccess() async {
    final available =
        await canScheduleExactAlarms();

    if (available) {
      return true;
    }

    return alarmManagerService
        .openExactAlarmSettings();
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

    if (
      alarm.scheduledTime
          .isBefore(DateTime.now())
    ) {
      return false;
    }

    // ==========================================================
    // CHECK EXACT ALARM ACCESS
    // ==========================================================

    final exactAlarmAvailable =
        await canScheduleExactAlarms();

    if (!exactAlarmAvailable) {
      return false;
    }

    // ==========================================================
    // SCHEDULE NATIVE ANDROID ALARM
    // ==========================================================

    final success =
        await alarmManagerService.scheduleAlarm(
      alarmId: alarm.id,
      scheduledTime: alarm.scheduledTime,
      label: alarm.label ??
          'Your Vayu alarm is ringing.',
    );

    // ==========================================================
    // SHOW OPTIONAL SCHEDULE CONFIRMATION
    // ==========================================================

    if (success) {
      await notificationController.showAlarmScheduled(
        alarm,
      );
    }

    return success;
  }

  // ============================================================
  // CANCEL ALARM
  // ============================================================

  Future<bool> cancelAlarm(
    String alarmId,
  ) async {

    final success =
        await alarmManagerService.cancelAlarm(
      alarmId: alarmId,
    );

    if (success) {
      await notificationController
          .cancelAlarmNotification(
        alarmId,
      );
    }

    return success;
  }

  // ============================================================
  // RESCHEDULE ALARM
  // ============================================================

  Future<bool> rescheduleAlarm(
    VayuAlarm alarm,
  ) async {

    if (!alarm.enabled) {
      await cancelAlarm(alarm.id);
      return false;
    }

    if (
      alarm.scheduledTime
          .isBefore(DateTime.now())
    ) {
      return false;
    }

    final exactAlarmAvailable =
        await canScheduleExactAlarms();

    if (!exactAlarmAvailable) {
      return false;
    }

    return alarmManagerService
        .rescheduleAlarm(
      alarmId: alarm.id,
      scheduledTime: alarm.scheduledTime,
      label: alarm.label ??
          'Your Vayu alarm is ringing.',
    );
  }

  // ============================================================
  // TRIGGER ALARM
  // ============================================================

  Future<void> triggerAlarm(
    VayuAlarm alarm,
  ) async {

    await notificationController.showAlarm(
      alarm,
    );
  }

  // ============================================================
  // CANCEL ALL
  // ============================================================

  Future<void> cancelAll() async {

    final alarms =
        await alarmService.getAlarms();

    for (final alarm in alarms) {
      await cancelAlarm(alarm.id);
    }

    await notificationController
        .cancelAllNotifications();
  }

  // ============================================================
  // OPEN APP SETTINGS
  // ============================================================

  Future<bool> openAppSettings() {
    return alarmManagerService
        .openAppSettings();
  }
}
