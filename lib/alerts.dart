import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';


class AlertUtils {
  static Future<void> showPopup({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    return showModalBottomSheet(
  context: context,
  backgroundColor: Colors.transparent,             // if you want rounded corners blend
  builder: (_) => Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black26)],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(message, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        )
      ],
    ),
  ),
);
  }
}
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _channelID = 'garden_alerts';
  static const _channelName = 'Garden Alerts';

}
