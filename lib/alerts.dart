import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// A simple model for one alert
class AlertData {
  final String title;
  final String message;
  AlertData(this.title, this.message);
}

/// Holds the current list of alerts and notifies listeners on changes
final ValueNotifier<List<AlertData>> alertsNotifier = ValueNotifier([]);

class AlertUtils {
  /// Enqueue a new alert (and fire a system notification if you like)
  static void showPopup({
    required String title,
    required String message,
    bool alsoNotify = true,
  }) {
    // 1) add to the notifier’s list
    final current = List<AlertData>.from(alertsNotifier.value);
    current.add(AlertData(title, message));
    alertsNotifier.value = current;

    // 2) optionally fire a system notification
    if (alsoNotify) {
      NotificationService._instance.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: message,
      );
    }
  }
}

/// A singleton notification helper
class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
        macOS: DarwinInitializationSettings()
      ),
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) =>
      _plugin.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'alerts_channel',
            'Alerts',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
      );
}
