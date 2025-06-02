import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:finance_management/presentation/routes.dart';
import 'package:finance_management/presentation/shared_data.dart';

class NotificationHelper {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        if (response.payload != null) {
          final chatRoomId = response.payload;
          // Navigate to chat screen with chatRoomId
          router.go(
            '${ProfileOnlineSupportHelperCenterScreen.routeName}?chatRoomId=$chatRoomId',
          );
        }
      },
    );
  }

  static Future<void> show(
    String title,
    String body, {
    String? chatRoomId,
  }) async {
    const android = AndroidNotificationDetails(
      'chat_channel',
      'Chat Messages',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: android);
    await _notifications.show(0, title, body, details, payload: chatRoomId);
  }
}

// Global navigator key for accessing context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
