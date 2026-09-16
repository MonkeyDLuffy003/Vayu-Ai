import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // ============================================================
  // NOTIFICATION PLUGIN
  // ============================================================

  final FlutterLocalNotificationsPlugin
      _notifications =
      FlutterLocalNotificationsPlugin();

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings =
        InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse:
          _onNotificationResponse,
    );
  }

  // ============================================================
  // NOTIFICATION RESPONSE
  // ============================================================

  void _onNotificationResponse(
    NotificationResponse response,
  ) {
    // Future:
    // - Open Vayu
    // - Open alarm screen
    // - Execute notification action
    //
    // Keep this callback lightweight.
  }

  // ============================================================
  // REQUEST NOTIFICATION PERMISSION
  // ============================================================

  Future<bool> requestPermission() async {
    final androidImplementation =
        _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation == null) {
      return false;
    }

    final granted =
        await androidImplementation
            .requestNotificationsPermission();

    return granted ?? false;
  }

  // ============================================================
  // SHOW IMMEDIATE NOTIFICATION
  // ============================================================

  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails =
        AndroidNotificationDetails(
      'vayu_general',
      'Vayu Notifications',
      channelDescription:
          'General notifications from Vayu AI.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details =
        NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      details,
    );
  }

  // ============================================================
  // SHOW ALARM NOTIFICATION
  // ============================================================

  Future<void> showAlarmNotification({
    required int id,
    required String label,
  }) async {
    const androidDetails =
        AndroidNotificationDetails(
      'vayu_alarms',
      'Vayu Alarms',
      channelDescription:
          'Alarm notifications from Vayu AI.',
      importance: Importance.max,
      priority: Priority.max,
      category:
          AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      enableVibration: true,
    );

    const details =
        NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      id,
      'Vayu Alarm',
      label.isEmpty
          ? 'Your alarm is ringing.'
          : label,
      details,
    );
  }

  // ============================================================
  // CANCEL ONE NOTIFICATION
  // ============================================================

  Future<void> cancel(
    int id,
  ) async {
    await _notifications.cancel(
      id,
    );
  }

  // ============================================================
  // CANCEL ALL NOTIFICATIONS
  // ============================================================

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
