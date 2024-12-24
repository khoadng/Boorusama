// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:version/version.dart';

// Project imports:
import '../../../backups/data_converter.dart';
import '../../../backups/import/backward_import_alert_dialog.dart';
import '../../../foundation/version.dart';
import '../../../info/package_info.dart';
import '../booru_config.dart';
import '../manage/booru_config_provider.dart';
import 'booru_config_export_data.dart';
import 'providers.dart';

mixin BooruConfigExportImportMixin on Notifier<List<BooruConfig>> {
  Future<void> import({
    required String path,
    required BuildContext context,
    void Function(String message)? onFailure,
    void Function(String message, List<BooruConfig> configs)? onSuccess,
    Future<bool> Function(BooruConfigExportData data)? onWillImport,
  }) async {
    final configRepo = ref.read(booruConfigRepoProvider);

    await ref
        .read(booruConfigFileHandlerProvider)
        .import(
          from: path,
        )
        .run()
        .then(
          (value) => value.fold(
            (l) => onFailure?.call(l.toString()),
            (r) async {
              final appVersion = ref.read(appVersionProvider);
              if (appVersion.significantlyLowerThan(r.exportVersion)) {
                final shouldImport = await showBackwardImportAlertDialog(
                  context: context,
                  data: r.exportData,
                );

                if (shouldImport == null || !shouldImport) return;
              }

              final willImport = await onWillImport?.call(r);
              if (willImport == null || !willImport) return;

              await configRepo.clear();
              state = await configRepo.addAll(r.data);
              onSuccess?.call('Imported successfully', r.data);
            },
          ),
        );
  }

  Future<void> export({
    required String path,
    void Function(String message)? onFailure,
    void Function(String message)? onSuccess,
  }) async {
    await ref
        .read(booruConfigFileHandlerProvider)
        .export(
          configs: state,
          path: path,
        )
        .run()
        .then(
          (value) => value.fold(
            (l) => onFailure?.call(l.toString()),
            (r) {
              onSuccess?.call('Exported successfully');
            },
          ),
        );
  }

  Future<void> exportClipboard({
    required Version? appVersion,
    void Function(String message)? onFailure,
    void Function(String message)? onSuccess,
  }) async {
    await ref.read(booruConfigFileHandlerProvider).exportToClipboard(
          configs: state,
          onSucceed: () => onSuccess?.call('Copied to clipboard'),
          onError: (e) => onFailure?.call(e),
        );
  }

  Future<void> importClipboard({
    void Function(String message)? onFailure,
    void Function(String message, List<BooruConfig> configs)? onSuccess,
    Future<bool> Function(BooruConfigExportData data)? onWillImport,
  }) async {
    await ref.read(booruConfigFileHandlerProvider).importFromClipboard().then(
          (value) => value.fold(
            (l) => onFailure?.call(l.toString()),
            (r) async {
              final willImport = await onWillImport?.call(r);
              if (willImport == null || !willImport) return;

              final configRepo = ref.read(booruConfigRepoProvider);

              await configRepo.clear();
              state = await configRepo.addAll(r.data);
              onSuccess?.call('Imported successfully', r.data);
            },
          ),
        );
  }

  Future<void> importFromRawString({
    required String jsonString,
    void Function(String message)? onFailure,
    void Function(String message, List<BooruConfig> configs)? onSuccess,
    Future<bool> Function(BooruConfigExportData data)? onWillImport,
  }) async {
    return tryDecodeData(data: jsonString)
        .map(
      (a) => BooruConfigExportData(
        data: a.data.map((e) => BooruConfig.fromJson(e)).toList(),
        exportData: a,
      ),
    )
        .fold(
      (l) {
        onFailure?.call(l.toString());
      },
      (data) async {
        final willImport = await onWillImport?.call(data);
        if (willImport == null || !willImport) return;

        final configRepo = ref.read(booruConfigRepoProvider);

        await configRepo.clear();
        state = await configRepo.addAll(data.data);
        onSuccess?.call('Imported successfully', data.data);
      },
    );
  }
}
