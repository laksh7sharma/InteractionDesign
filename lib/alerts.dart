import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';


class AlertUtils {
  static Future<void> showPopup({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _channelID = 'garden_alerts';
  static const _channelName = 'Garden Alerts';

}
