import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // ============================================================
  // MICROPHONE
  // ============================================================

  Future<bool> requestMicrophone() async {
    final status =
        await Permission.microphone.request();

    return status.isGranted;
  }

  Future<bool> hasMicrophonePermission() async {
    return await Permission.microphone.isGranted;
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  Future<bool> requestNotifications() async {
    final status =
        await Permission.notification.request();

    return status.isGranted;
  }

  Future<bool> hasNotificationPermission() async {
    return await Permission.notification.isGranted;
  }

  // ============================================================
  // CAMERA
  // ============================================================

  Future<bool> requestCamera() async {
    final status =
        await Permission.camera.request();

    return status.isGranted;
  }

  Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }

  // ============================================================
  // STORAGE / PHOTOS
  // ============================================================

  Future<bool> requestPhotos() async {
    final status =
        await Permission.photos.request();

    return status.isGranted;
  }

  Future<bool> hasPhotosPermission() async {
    return await Permission.photos.isGranted;
  }

  // ============================================================
  // OPEN APP SETTINGS
  // ============================================================

  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  // ============================================================
  // PERMISSION STATUS
  // ============================================================

  Future<PermissionStatus> microphoneStatus() async {
    return await Permission.microphone.status;
  }

  Future<PermissionStatus> notificationStatus() async {
    return await Permission.notification.status;
  }

  Future<PermissionStatus> cameraStatus() async {
    return await Permission.camera.status;
  }

  // ============================================================
  // BACKGROUND / SPECIAL ACCESS
  // ============================================================

  Future<bool> requestBackgroundPermissions() async {
    // Android background execution is not one universal
    // runtime permission.
    //
    // Actual background services, alarms, battery optimization,
    // foreground services and exact-alarm access will be handled
    // by their dedicated implementations.
    //
    // This method intentionally does not request unsupported
    // permissions blindly.

    return true;
  }

  // ============================================================
  // REQUEST VOICE PERMISSIONS
  // ============================================================

  Future<bool> requestVoicePermissions() async {
    final microphoneGranted =
        await requestMicrophone();

    if (!microphoneGranted) {
      return false;
    }

    return true;
  }

  // ============================================================
  // REQUEST ALARM-RELATED PERMISSIONS
  // ============================================================

  Future<bool> requestAlarmPermissions() async {
    // Actual exact-alarm/background alarm handling will be added
    // when the Android alarm scheduler is implemented.
    //
    // Keeping this separate prevents Vayu from requesting
    // unnecessary permissions at this stage.

    return true;
  }
}
