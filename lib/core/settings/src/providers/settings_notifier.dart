// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../analytics.dart';
import '../../../backups/import/backward_import_alert_dialog.dart';
import '../../../foundation/loggers/providers.dart';
import '../../../foundation/toast.dart';
import '../../../foundation/version.dart';
import '../../../info/package_info.dart';
import '../data/providers.dart';
import '../data/settings_io_handler.dart';
import '../types/settings.dart';

final settingsNotifierProvider = NotifierProvider<SettingsNotifier, Settings>(
  () => throw UnimplementedError(),
  name: 'settingsNotifierProvider',
);

class SettingsNotifier extends Notifier<Settings> {
  SettingsNotifier(this.initialSettings);

  final Settings initialSettings;

  @override
  Settings build() {
    return initialSettings;
  }

  Future<void> updateWith(
    Settings Function(Settings) selector,
  ) async {
    final currentSettings = state;
    final newSettings = selector(currentSettings);

    return updateSettings(newSettings);
  }

  Future<void> updateSettings(Settings settings) async {
    final currentSettings = state;
    final success = await ref.read(settingsRepoProvider).save(settings);

    if (success) {
      for (var i = 0; i < currentSettings.props.length; i++) {
        final cs = currentSettings.props[i];
        final ns = settings.props[i];

        if (cs != ns) {
          ref.read(loggerProvider).logI(
                'Settings',
                'Settings updated: ${cs.runtimeType} $cs -> $ns',
              );
        }
      }
      state = settings;

      ref.read(analyticsProvider).whenData(
            (a) => a.logSettingsChangedEvent(
              oldValue: currentSettings,
              newValue: settings,
            ),
          );
    }
  }

  Future<void> importSettings({
    required String path,
    required BuildContext context,
    void Function(String message)? onFailure,
    void Function(String message, Settings)? onSuccess,
    Future<bool> Function(SettingsExportData data)? onWillImport,
  }) async {
    await ref
        .read(settingIOHandlerProvider)
        .import(
          from: path,
        )
        .run()
        .then(
          (value) => value.fold(
            (l) => showErrorToast(context, l.toString()),
            (r) async {
              //FIXME: Duplicate code, abstract import with check
              final appVersion = ref.read(appVersionProvider);
              if (appVersion
                  .significantlyLowerThan(r.exportData.exportVersion)) {
                final shouldImport = await showBackwardImportAlertDialog(
                  context: context,
                  data: r.exportData,
                );

                if (shouldImport == null || !shouldImport) return;
              }

              final willImport = await onWillImport?.call(r);
              if (willImport == null || !willImport) return;

              await updateSettings(r.data);

              onSuccess?.call('Imported successfully', r.data);
            },
          ),
        );
  }

  Future<void> exportSettings(BuildContext context, String path) async {
    await ref
        .read(settingIOHandlerProvider)
        .export(
          state,
          to: path,
        )
        .run()
        .then(
          (value) => value.fold(
            (l) => showErrorToast(context, l.toString()),
            (r) => showSuccessToast(context, 'Settings exported to $path'),
          ),
        );
  }
}
