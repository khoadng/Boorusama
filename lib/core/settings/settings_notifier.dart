// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/backups/backups.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/foundation/package_info.dart';
import 'package:boorusama/foundation/toast.dart';
import 'package:boorusama/foundation/version.dart';

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
              'Settings', 'Settings updated: ${cs.runtimeType} $cs -> $ns');
        }
      }
      state = settings;
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

extension SettingsNotifierX on SettingsNotifier {
  Future<void> updateOrder(List<int> configIds) => updateWith(
        (settings) => settings.copyWith(
          booruConfigIdOrders: configIds.join(' '),
        ),
      );
}

extension SettingsNotifierWidgetRefX on WidgetRef {
  Future<void> updateSettings(Settings settings) =>
      read(settingsProvider.notifier).updateSettings(settings);
}
