import 'alarm_controller.dart';
import 'notification_service.dart';

class NotificationController {
  final NotificationService _notificationService;
  final AlarmController _alarmController;

  NotificationController({
    required NotificationService notificationService,
    required AlarmController alarmController,
  })  : _notificationService = notificationService,
        _alarmController = alarmController;

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> initialize() async {
    await _notificationService.initialize();
  }

  // ============================================================
  // REQUEST PERMISSION
  // ============================================================

  Future<bool> requestPermission() async {
    return await _notificationService
        .requestPermission();
  }

  // ============================================================
  // SHOW TEST NOTIFICATION
  // ============================================================

  Future<void> showTestNotification() async {
    await _notificationService.show(
      id: 1001,
      title: 'Vayu AI',
      body:
          'Systems are online, Sir.',
    );
  }

  // ============================================================
  // SHOW ALARM NOTIFICATION
  // ============================================================

  Future<void> showAlarm({
    required int alarmId,
    String? label,
  }) async {
    await _notificationService
        .showAlarmNotification(
      id: alarmId,
      label: label ?? '',
    );
  }

  // ============================================================
  // CANCEL ALARM NOTIFICATION
  // ============================================================

  Future<void> cancelAlarmNotification(
    int alarmId,
  ) async {
    await _notificationService.cancel(
      alarmId,
    );
  }

  // ============================================================
  // CANCEL ALL
  // ============================================================

  Future<void> cancelAllNotifications() async {
    await _notificationService.cancelAll();
  }

  // ============================================================
  // GET NEXT ALARM
  // ============================================================

  Future<DateTime?> getNextAlarmTime() async {
    final alarm =
        await _alarmController.getNextAlarm();

    return alarm?.scheduledTime;
  }
}
