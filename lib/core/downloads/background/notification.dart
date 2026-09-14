// Dart imports:
import 'dart:async';

// Package imports:
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Project imports:
import '../../../foundation/platform.dart';

class DownloadNotifications {
  DownloadNotifications.uninitialized({required this.platform})
    : _flutterLocalNotificationsPlugin = null,
      _tapController = StreamController<String>.broadcast();

  final AppPlatform platform;
  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;
  final StreamController<String> _tapController;
  var _isInitialized = false;
  Future<void>? _initialization;
  final _activeBulkNotifications = <String>{};

  Stream<String> get tapStream => _tapController.stream;

  Future<void> _ensureInitialized() async {
    if (_isInitialized || platform == AppPlatform.windows) return;

    final pending = _initialization;
    if (pending != null) {
      await pending;
      return;
    }

    final initialization = _initialize();
    _initialization = initialization;
    try {
      await initialization;
    } finally {
      _initialization = null;
    }
  }

  Future<void> _initialize() async {
    final plugin = FlutterLocalNotificationsPlugin();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
      linux: LinuxInitializationSettings(
        defaultActionName: 'Open notification',
      ),
    );
    await plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        _tapController.add(response.payload ?? response.id.toString());
      },
    );
    _flutterLocalNotificationsPlugin = plugin;
    _isInitialized = true;
  }

  void configureNativeDownloads({required bool enabled}) {
    FileDownloader().configureNotificationForGroup(
      FileDownloader.defaultGroup,
      running: enabled
          ? const TaskNotification('{filename}', '{progress}')
          : null,
      complete: enabled
          ? const TaskNotification('{filename}', 'completed')
          : null,
      error: enabled ? const TaskNotification('{filename}', 'failed') : null,
      progressBar: enabled,
    );
  }

  void registerNativeTapCallback() {
    FileDownloader().registerCallbacks(
      taskNotificationTapCallback: (task, type) {
        _tapController.add('native:${type.name}');
      },
    );
  }

  Future<void> showDownloadCompleteNotification(
    String filename, {
    String? customMessage,
    bool fromCache = false,
  }) async {
    if (platform == AppPlatform.windows) return;

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
      id: 'complete_${filename.hashCode}'.hashCode,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
      payload: 'native:complete',
    );
  }

  Future<void> showDownloadErrorNotification(
    String filename, {
    String? error,
  }) async {
    if (platform == AppPlatform.windows) return;

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
      id: 'error_${filename.hashCode}'.hashCode,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
      payload: 'native:error',
    );
  }

  Future<void> showBulkPreparing(
    String sessionId,
    String title,
    String body,
  ) async {
    if (platform == AppPlatform.windows) return;
    await _ensureInitialized();

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'download_$sessionId',
        'Download Progress',
        channelDescription: 'Shows download progress for bulk downloads',
        playSound: false,
        enableVibration: false,
        category: AndroidNotificationCategory.progress,
        showProgress: true,
        indeterminate: true,
        ongoing: true,
        autoCancel: false,
      ),
      iOS: const DarwinNotificationDetails(presentSound: false),
    );

    await _flutterLocalNotificationsPlugin?.show(
      id: sessionId.hashCode,
      title: title,
      body: body,
      notificationDetails: details,
      payload: 'bulk:$sessionId',
    );
    _activeBulkNotifications.add(sessionId);
  }

  Future<void> showBulkProgress(
    String sessionId,
    String title, {
    required int completed,
    required int total,
  }) async {
    if (platform == AppPlatform.windows) return;
    await _ensureInitialized();

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
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
      ),
      iOS: const DarwinNotificationDetails(presentSound: false),
    );

    await _flutterLocalNotificationsPlugin?.show(
      id: sessionId.hashCode,
      title: title,
      body: '$completed/$total files',
      notificationDetails: details,
      payload: 'bulk:$sessionId',
    );
    _activeBulkNotifications.add(sessionId);
  }

  Future<void> showBulkComplete(
    String sessionId,
    String title, {
    required int total,
  }) async {
    if (platform == AppPlatform.windows) return;
    await _ensureInitialized();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'download',
        'Download',
        category: AndroidNotificationCategory.status,
      ),
      iOS: DarwinNotificationDetails(presentSound: false),
    );

    await _flutterLocalNotificationsPlugin?.show(
      id: sessionId.hashCode,
      title: title,
      body: 'Downloaded $total files',
      notificationDetails: details,
      payload: 'bulk:$sessionId',
    );
    _activeBulkNotifications.remove(sessionId);
  }

  Future<void> cancelBulk(String sessionId) async {
    if (platform == AppPlatform.windows) return;
    await _ensureInitialized();
    await _flutterLocalNotificationsPlugin?.cancel(id: sessionId.hashCode);
    _activeBulkNotifications.remove(sessionId);
  }

  Future<void> cancelAllBulk() async {
    for (final sessionId in _activeBulkNotifications.toList()) {
      await cancelBulk(sessionId);
    }
  }

  void dispose() {
    unawaited(_tapController.close());
  }
}
