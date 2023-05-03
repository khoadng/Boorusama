// Package imports:
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/core/platform.dart';

class NotificationError {
  NotificationError(this.message);

  final String message;
}

class DownloadNotifications {
  DownloadNotifications._(this._flutterLocalNotificationsPlugin);

  static Future<DownloadNotifications> create() async {
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

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  Future<void> showInProgress(String fileName) {
    return _showNotification(fileName, 'in progress');
  }

  Future<void> showCompleted(String fileName) {
    return _showNotification(fileName, 'completed', payload: fileName);
  }

  Future<void> showFailed(String fileName) {
    return _showNotification(fileName, 'failed', payload: fileName);
  }

  Future<void> _showNotification(String title, String body,
      {String? payload}) async {
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

    await _flutterLocalNotificationsPlugin.show(
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
      //TODO: download path is hard-coded
      data: Uri.parse('/storage/emulated/0/Pictures/${response.payload}')
          .toString(),
      flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    await intent.launch();
  }
}
