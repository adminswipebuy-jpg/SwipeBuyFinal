import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_service.dart';

class PushNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final NotificationService _notificationService = NotificationService();

  Future<void> initialize() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _messaging.getToken();
    if (token != null) {
      await _notificationService.registerDeviceToken(token);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      await _notificationService.registerDeviceToken(token);
    });
  }
}
