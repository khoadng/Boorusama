// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:oktoast/oktoast.dart';

// Project imports:
import 'package:boorusama/core/download_activity/activity.dart';
import 'package:boorusama/core/downloads/background/notification.dart';
import 'package:boorusama/core/downloads/background/providers.dart';
import 'package:boorusama/core/settings/providers.dart';
import 'package:boorusama/core/settings/types.dart';
import 'package:boorusama/foundation/loggers.dart';
import 'package:boorusama/foundation/permissions.dart';

final _activitiesProvider = StateProvider<List<DownloadActivity>>(
  (ref) => const [],
);

class DownloadActivityScopeHarness {
  DownloadActivityScopeHarness({
    bool useRealActivities = false,
    List<Override> overrides = const [],
  }) : _notifications = _RecordingDownloadNotifications(),
       _permissionManager = _RecordingNotificationPermissionManager(),
       _settingsNotifier = _TestSettingsNotifier(Settings.defaultSettings) {
    _container = ProviderContainer(
      overrides: [
        settingsNotifierProvider.overrideWith(() => _settingsNotifier),
        if (!useRealActivities)
          downloadActivitiesProvider.overrideWith(
            (ref) => ref.watch(_activitiesProvider),
          ),
        downloadNotificationsProvider.overrideWithValue(_notifications),
        notificationPermissionManagerProvider.overrideWithValue(
          _permissionManager,
        ),
        ...overrides,
      ],
    );
  }

  final _RecordingDownloadNotifications _notifications;
  final _RecordingNotificationPermissionManager _permissionManager;
  final _TestSettingsNotifier _settingsNotifier;
  late final ProviderContainer _container;

  List<String> get notificationEvents => _notifications.events;

  int get permissionRequestCount => _permissionManager.requestCount;

  void setProgressGate(Completer<void>? value) {
    _notifications.progressGate = value;
  }

  Future<void> pump(WidgetTester tester) {
    return tester.pumpWidget(
      UncontrolledProviderScope(
        container: _container,
        child: BooruLocalization(
          child: OKToast(
            child: MaterialApp(
              builder: (context, child) => KurumiTheme(
                data: KurumiThemeData.fromMaterial(Theme.of(context)),
                child: child!,
              ),
              home: const DownloadActivityScope(
                child: SizedBox(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void setActivities(List<DownloadActivity> activities) {
    _container.read(_activitiesProvider.notifier).state = activities;
  }

  void setNotificationsEnabled(bool enabled) {
    _settingsNotifier.setNotificationsEnabled(enabled);
  }

  void clearNotificationEvents() {
    _notifications.events.clear();
  }

  void dispose() {
    _container.dispose();
  }
}

class _TestSettingsNotifier extends SettingsNotifier {
  _TestSettingsNotifier(super.initialSettings);

  void setNotificationsEnabled(bool enabled) {
    state = state.copyWith(downloadNotificationsEnabled: enabled);
  }
}

class _RecordingNotificationPermissionManager
    extends NotificationPermissionManager {
  _RecordingNotificationPermissionManager()
    : super(logger: const _NoopLogger());

  var requestCount = 0;

  @override
  Future<void> requestIfNotGranted() async {
    requestCount++;
  }
}

class _RecordingDownloadNotifications extends DownloadNotifications {
  _RecordingDownloadNotifications() : super.uninitialized();

  final events = <String>[];
  Completer<void>? progressGate;

  @override
  void configureNativeDownloads({required bool enabled}) {
    events.add('configure:$enabled');
  }

  @override
  void registerNativeTapCallback() {
    events.add('registerNativeTap');
  }

  @override
  Future<void> showDownloadCompleteNotification(
    String filename, {
    String? customMessage,
    bool fromCache = false,
  }) async {
    events.add('singleComplete:$filename:$fromCache:$customMessage');
  }

  @override
  Future<void> showBulkPreparing(
    String sessionId,
    String title,
    String body,
  ) async {
    events.add('bulkPreparing:$sessionId');
  }

  @override
  Future<void> showBulkProgress(
    String sessionId,
    String title, {
    required int completed,
    required int total,
  }) async {
    events.add('bulkProgress:start');
    await progressGate?.future;
    events.add('bulkProgress:end');
  }

  @override
  Future<void> showBulkComplete(
    String sessionId,
    String title, {
    required int total,
  }) async {
    events.add('bulkComplete:$sessionId:$total');
  }

  @override
  Future<void> cancelBulk(String sessionId) async {
    events.add('cancelBulk:$sessionId');
  }

  @override
  Future<void> cancelAllBulk() async {
    events.add('cancelAllBulk');
  }
}

class _NoopLogger implements Logger {
  const _NoopLogger();

  @override
  void debug(String serviceName, String message, {String? sensitiveMessage}) {}

  @override
  void error(String serviceName, String message, {String? sensitiveMessage}) {}

  @override
  String getDebugName() => 'noop';

  @override
  void info(String serviceName, String message, {String? sensitiveMessage}) {}

  @override
  void verbose(
    String serviceName,
    String message, {
    String? sensitiveMessage,
  }) {}

  @override
  void warn(String serviceName, String message, {String? sensitiveMessage}) {}
}
