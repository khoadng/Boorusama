// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Project imports:
import '../../../foundation/platform.dart';

class BulkDownloadNotifications {
  BulkDownloadNotifications._(
    this._flutterLocalNotificationsPlugin,
    this._streamController,
  );

  final StreamController<String>? _streamController;

  Stream<String> get tapStream =>
      _streamController?.stream ?? const Stream.empty();

  static Future<BulkDownloadNotifications> create() async {
    if (isWindows()) {
      return BulkDownloadNotifications._(null, null);
    }

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
      linux:
          LinuxInitializationSettings(defaultActionName: 'Open notification'),
    );

    //TODO: dispose?
    final streamController = StreamController<String>.broadcast();

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (_) => streamController.add(''),
    );

    final notif = BulkDownloadNotifications._(
      flutterLocalNotificationsPlugin,
      streamController,
    );

    return notif;
  }

  final FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;

  Future<void> showNotification(
    String title,
    String body, {
    String? payload,
    int? progress,
    int? total,
    bool? indeterminate,
  }) async {
    //TODO: implement custom notification for windows
    if (isWindows()) return;

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'download',
      'Download',
      playSound: false,
      enableVibration: false,
      category: AndroidNotificationCategory.progress,
      showProgress: progress != null && total != null,
      maxProgress: total ?? 0,
      progress: progress ?? 0,
      indeterminate: indeterminate ?? false,
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
