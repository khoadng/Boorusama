// Package imports:
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/foundation/platform.dart';

class NotificationError {
  NotificationError(this.message);

  final String message;
}

class DownloadNotifications {
  DownloadNotifications._(this._flutterLocalNotificationsPlugin);

  static Future<DownloadNotifications> create() async {
    if (isWindows()) {
      return DownloadNotifications._(null);
    }

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _localNotificatonHandler,
    );

    return DownloadNotifications._(flutterLocalNotificationsPlugin);
  }

  final FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;

  Future<void> showInProgress(String fileName, String path) {
    return _showNotification(fileName, 'in progress', payload: path);
  }

  Future<void> showCompleted(String fileName, String path) {
    return _showNotification(fileName, 'completed', payload: path);
  }

  Future<void> showFailed(String fileName, String path) {
    return _showNotification(fileName, 'failed', payload: path);
  }

  Future<void> _showNotification(String title, String body,
      {String? payload}) async {
    //TODO: implement custom notification for windows
    if (isWindows()) return;

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      title,
      title,
      playSound: false,
      enableVibration: false,
    );
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: const DarwinNotificationDetails(
        presentSound: false,
      ),
    );

    await _flutterLocalNotificationsPlugin?.show(
      title.hashCode,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}

Future<void> _localNotificatonHandler(NotificationResponse response) async {
  if (response.payload == null) return;
  if (isIOS()) {
    //TODO: update usage for iOS
    final uri = Uri.parse('photos-redirect://');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  } else if (isAndroid()) {
    final intent = AndroidIntent(
      action: 'action_view',
      type: 'image/*',
      data: Uri.parse('${response.payload}').toString(),
      flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    await intent.launch();
  }
}
