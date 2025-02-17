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
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
      linux:
          LinuxInitializationSettings(defaultActionName: 'Open notification'),
    );

    // No need to close cause it is used in the main function
    // ignore: close_sinks
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
  final _activeNotifications = <String, bool>{};

  Future<void> showOneShotNotification(
    String title,
    String body, {
    String? payload,
  }) async {
    //TODO: implement custom notification for windows
    if (isWindows()) return;

    const platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'download',
        'Download',
        playSound: false,
        enableVibration: false,
      ),
      iOS: DarwinNotificationDetails(
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

  Future<void> showNotification(
    String title,
    String body, {
    String? payload,
    int? progress,
    int? total,
    bool? indeterminate,
    int? notificationId,
  }) async {
    //TODO: implement custom notification for windows
    if (isWindows()) return;

    final id = notificationId ?? title.hashCode;

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'download',
      'Download',
      playSound: false,
      enableVibration: false,
      category: AndroidNotificationCategory.progress,
      showProgress: true,
      maxProgress: total ?? 0,
      progress: progress ?? 0,
      indeterminate: indeterminate ?? false,
      ongoing: true,
      autoCancel: false,
    );

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: const DarwinNotificationDetails(
        presentSound: false,
      ),
    );

    await _flutterLocalNotificationsPlugin?.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );

    if (indeterminate == true) {
      _activeNotifications[id.toString()] = true;
    }
  }

  Future<void> showProgressNotification(
    String sessionId,
    String title,
    String body, {
    required int completed,
    required int total,
  }) async {
    if (isWindows()) return;

    _activeNotifications[sessionId] = true;

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'download_$sessionId',
      'Download Progress',
      channelDescription: 'Shows download progress for bulk downloads',
      playSound: false,
      enableVibration: false,
      category: AndroidNotificationCategory.progress,
      showProgress: true,
      maxProgress: total,
      progress: completed,
      ongoing: true,
      autoCancel: false,
    );

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: const DarwinNotificationDetails(
        presentSound: false,
      ),
    );

    await _flutterLocalNotificationsPlugin?.show(
      sessionId.hashCode,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> cancelNotification(String sessionId) async {
    if (isWindows()) return;
    if (_activeNotifications[sessionId] != true) return;

    await _flutterLocalNotificationsPlugin?.cancel(sessionId.hashCode);
    _activeNotifications.remove(sessionId);
  }

  void dispose() {
    _streamController?.close();
  }
}
