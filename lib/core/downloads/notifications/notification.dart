// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Project imports:
import '../../../foundation/platform.dart';

class DownloadNotifications {
  DownloadNotifications._(
    this._flutterLocalNotificationsPlugin,
  );

  DownloadNotifications.uninitialized()
    : _flutterLocalNotificationsPlugin = null;

  static Future<DownloadNotifications> create() async {
    if (isWindows()) {
      return DownloadNotifications._(null);
    }

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
      linux: LinuxInitializationSettings(
        defaultActionName: 'Open notification',
      ),
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    final notif = DownloadNotifications._(flutterLocalNotificationsPlugin);

    return notif;
  }

  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;
  var _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (_isInitialized || isWindows()) return;

    final initialized = await create();
    _flutterLocalNotificationsPlugin =
        initialized._flutterLocalNotificationsPlugin;
    _isInitialized = true;
  }

  Future<void> showDownloadCompleteNotification(
    String filename, {
    String? customMessage,
    bool fromCache = false,
  }) async {
    if (isWindows()) return;

    await _ensureInitialized();

    final title = fromCache
        ? 'Download complete (disk cached)'
        : 'Download complete';
    final body =
        customMessage ??
        (fromCache
            ? '$filename saved instantly from cache'
            : '$filename ready in Downloads');

    const platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'downloads',
        'Downloads',
        channelDescription: 'Download notifications',
        category: AndroidNotificationCategory.status,
      ),
      iOS: DarwinNotificationDetails(
        presentSound: false,
      ),
    );

    await _flutterLocalNotificationsPlugin?.show(
      'complete_${filename.hashCode}'.hashCode,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> showDownloadErrorNotification(
    String filename, {
    String? error,
  }) async {
    if (isWindows()) return;

    await _ensureInitialized();

    const title = 'Download failed';
    final body = error ?? "Couldn't save $filename";

    const platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'downloads',
        'Downloads',
        channelDescription: 'Download notifications',
        category: AndroidNotificationCategory.error,
        importance: Importance.high,
      ),
      iOS: DarwinNotificationDetails(
        presentSound: false,
      ),
    );

    await _flutterLocalNotificationsPlugin?.show(
      'error_${filename.hashCode}'.hashCode,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
