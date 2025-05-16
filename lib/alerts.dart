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

  /// Enqueue and (if not already showing) display the alerts.
  static void showPopup({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    _queue.add(_Alert(title, message));
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
    return Container(
      height: 100,           // smaller height
      color: Colors.red,     // solid red, no rounding
      child: PageView.builder(
        controller: _controller,
        itemCount: _alerts.length,
        onPageChanged: (newPage) {
          // if we swiped forward, drop the alert we just left behind
          if (newPage > _currentPage) {
            setState(() {
              _alerts.removeAt(0);
            });
            // jump back to page 0 so the next alert is in view
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
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.message,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // no “X” button – users can swipe horizontally or drag down
              ],
            ),
          );
        },
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
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _channelID = 'garden_alerts';
  static const _channelName = 'Garden Alerts';

}
