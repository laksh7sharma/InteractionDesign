import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:collection';

class _Alert {
  final String title;
  final String message;
  _Alert(this.title, this.message);
}

class AlertUtils {
  static final Queue<_Alert> _queue = Queue<_Alert>();
  static bool _isShowing = false;
  static int _nextNotificationId = 0;
  /// Enqueue and (if not already showing) display the alerts.
  static void showPopup({
    required BuildContext context,
    required String title,
    required String message,
    bool alsoNotify = true,
  }) {
    _queue.add(_Alert(title, message));
    if (alsoNotify) {
      NotificationService().showNotification(
        id: _nextNotificationId++,
        title: title,
        body: message,
      );
    }
    if (!_isShowing) _showNext(context);
  }

  static Future<void> _showNext(BuildContext context) async {
    if (_queue.isEmpty) {
      _isShowing = false;
      return;
    }
    _isShowing = true;

    // 1) Grab everything in the queue now…
    final List<_Alert> alerts = List<_Alert>.from(_queue);
    // 2) …then clear it so future calls go into a fresh queue.
    _queue.clear();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent, // <-- no grey overlay
      isDismissible: true,
      enableDrag: true,
      builder: (_) => _AlertCarousel(initialAlerts: alerts),
    );

    _isShowing = false;
    // If new alerts arrived while this sheet was up, show them now:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_queue.isNotEmpty) _showNext(context);
    });
  }
}

class _AlertCarousel extends StatefulWidget {
  final List<_Alert> initialAlerts;
  const _AlertCarousel({Key? key, required this.initialAlerts})
      : super(key: key);

  @override
  _AlertCarouselState createState() => _AlertCarouselState();
}

class _AlertCarouselState extends State<_AlertCarousel> {
  late final PageController _controller;
  late List<_Alert> _alerts;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _alerts = List<_Alert>.from(widget.initialAlerts);
  }

  @override
Widget build(BuildContext context) {
  return Padding(
    // 1) gap from bottom and sides
    padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
    child: ClipRRect(
      // 2) rounded corners
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 100,
        color: Colors.red,
        child: PageView.builder(
          controller: _controller,
          itemCount: _alerts.length,
          onPageChanged: (newPage) {
            if (newPage > _currentPage) {
              setState(() => _alerts.removeAt(0));
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_alerts.isNotEmpty) _controller.jumpToPage(0);
              });
            }
            _currentPage = newPage;
          },
          itemBuilder: (ctx, i) {
            final alert = _alerts[i];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // 3a) center items horizontally
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    alert.title,
                    // 3b) center text inside its box
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );
}

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: iosSettings,
      ),
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'alerts_channel',            // channel id
      'Alerts',                    // channel name
      channelDescription: 'Queued alerts',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _flutterLocalNotificationsPlugin.show(
      id,       // unique id for each notification
      title,
      body,
      details,
    );
  }
}
