// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../foundation/permissions.dart';
import '../../foundation/platform.dart';
import '../bulk_downloads/routes.dart';
import '../downloads/background/notification.dart';
import '../downloads/background/providers.dart';
import '../downloads/downloader/src/providers/download_notifier.dart';
import '../downloads/downloader/types.dart';
import '../router.dart';
import '../settings/providers.dart';
import 'providers.dart';
import 'types.dart';

class DownloadActivityScope extends ConsumerStatefulWidget {
  const DownloadActivityScope({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  ConsumerState<DownloadActivityScope> createState() =>
      _DownloadActivityScopeState();
}

class _DownloadActivityScopeState extends ConsumerState<DownloadActivityScope> {
  var _requestedPermission = false;
  var _registeredNativeTap = false;
  bool? _configuredNotifications;
  Future<void>? _permissionRequest;
  final _notificationUpdates = <String, Future<void>>{};

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(
      settingsProvider.select((value) => value.downloadNotificationsEnabled),
    );
    final notifications = ref.watch(downloadNotificationsProvider);

    if (_configuredNotifications != enabled) {
      notifications.configureNativeDownloads(enabled: enabled);
      _configuredNotifications = enabled;
    }
    if (!_registeredNativeTap) {
      notifications.registerNativeTapCallback();
      _registeredNativeTap = true;
    }

    ref
      ..listen(downloadActivitiesProvider, (previous, current) {
        final previousById = {
          for (final activity in previous ?? const <DownloadActivity>[])
            activity.id: activity,
        };

        for (final activity in current) {
          final old = previousById[activity.id];
          if (old == activity) continue;

          if (_startsSingleDownload(old, activity)) {
            showDownloadStartToast(
              context,
              message: activity.phase == DownloadActivityPhase.waitingForWifi
                  ? context.t.download.status.waiting_for_wifi
                  : null,
            );
          }

          if (activity.kind == DownloadActivityKind.single &&
              activity.phase == DownloadActivityPhase.failed) {
            showDownloadErrorToast(
              context,
              activity.error ?? 'Download failed: ${activity.label}',
            );
          }

          if (enabled && !_requestedPermission) {
            _requestedPermission = true;
            _permissionRequest = ref
                .read(notificationPermissionManagerProvider)
                .requestIfNotGranted();
          }

          if (enabled) {
            _scheduleNotificationUpdate(notifications, activity);
          }
        }
      })
      ..listen(downloadNotificationTapProvider, (previous, current) {
        final value = current.valueOrNull;
        if (value == null) return;

        if (value.startsWith('native:')) {
          final filter = value.substring('native:'.length);
          ref.router.go(
            Uri(
              path: '/download_manager',
              queryParameters: {'filter': filter},
            ).toString(),
          );
        } else {
          goToBulkDownloadManagerPage(ref, go: true);
        }
      })
      ..listen(
        settingsProvider.select(
          (settings) => settings.downloadNotificationsEnabled,
        ),
        (previous, current) {
          notifications.configureNativeDownloads(enabled: current);
          _configuredNotifications = current;
          if (!current) {
            unawaited(notifications.cancelAllBulk());
            for (final activity in ref.read(downloadActivitiesProvider)) {
              if (activity.kind == DownloadActivityKind.bulk) {
                unawaited(notifications.cancelBulk(activity.id));
              }
            }
          }
        },
      );

    return widget.child;
  }

  bool _startsSingleDownload(
    DownloadActivity? previous,
    DownloadActivity activity,
  ) {
    if (activity.kind != DownloadActivityKind.single) return false;

    return switch (activity.phase) {
      DownloadActivityPhase.waitingForWifi => previous == null,
      DownloadActivityPhase.running =>
        previous == null || previous.phase == DownloadActivityPhase.queued,
      DownloadActivityPhase.completed || DownloadActivityPhase.skipped =>
        previous == null &&
            (activity.completionSource == DownloadCompletionSource.cache ||
                activity.completionSource ==
                    DownloadCompletionSource.alreadyPresent),
      _ => false,
    };
  }

  void _scheduleNotificationUpdate(
    DownloadNotifications notifications,
    DownloadActivity activity,
  ) {
    final previous = _notificationUpdates[activity.id] ?? Future.value();
    late final Future<void> update;
    update = previous
        .then((_) async {
          await _permissionRequest;
          await _updateNotification(notifications, activity);
        })
        .catchError((Object _) {})
        .whenComplete(() {
          if (identical(_notificationUpdates[activity.id], update)) {
            _notificationUpdates.remove(activity.id);
          }
        });
    _notificationUpdates[activity.id] = update;
  }

  Future<void> _updateNotification(
    DownloadNotifications notifications,
    DownloadActivity activity,
  ) async {
    final isIOS = ref.read(appPlatformProvider).isIOS;
    if (activity.kind == DownloadActivityKind.single) {
      if (activity.phase == DownloadActivityPhase.completed &&
          activity.completionSource == DownloadCompletionSource.cache) {
        await notifications.showDownloadCompleteNotification(
          activity.label,
          fromCache: true,
        );
      } else if (activity.phase == DownloadActivityPhase.skipped &&
          activity.completionSource ==
              DownloadCompletionSource.alreadyPresent) {
        await notifications.showDownloadCompleteNotification(
          activity.label,
          fromCache: true,
          customMessage: '${activity.label} was already saved',
        );
      }
      return;
    }

    switch (activity.phase) {
      case DownloadActivityPhase.preparing:
        await notifications.showBulkPreparing(
          activity.id,
          activity.label,
          'Preparing download',
        );
      case DownloadActivityPhase.running:
        final total = activity.totalItems;
        if (!isIOS && total != null && total > 0) {
          await notifications.showBulkProgress(
            activity.id,
            activity.label,
            completed: activity.completedItems ?? 0,
            total: total,
          );
        }
      case DownloadActivityPhase.completed:
        await notifications.cancelBulk(activity.id);
        await notifications.showBulkComplete(
          activity.id,
          activity.label,
          total: activity.totalItems ?? 0,
        );
      case DownloadActivityPhase.skipped ||
          DownloadActivityPhase.failed ||
          DownloadActivityPhase.cancelled ||
          DownloadActivityPhase.suspended:
        await notifications.cancelBulk(activity.id);
      case DownloadActivityPhase.queued ||
          DownloadActivityPhase.waitingForWifi ||
          DownloadActivityPhase.waitingToRetry ||
          DownloadActivityPhase.paused:
        break;
    }
  }
}
