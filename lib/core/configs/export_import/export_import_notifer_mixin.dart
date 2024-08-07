// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:version/version.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/backups/backups.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/export_import/export_import.dart';
import 'package:boorusama/foundation/package_info.dart';
import 'package:boorusama/foundation/version.dart';

mixin BooruConfigExportImportMixin on Notifier<List<BooruConfig>?> {
  // import from json
  Future<void> import({
    required String path,
    required BuildContext context,
    void Function(String message)? onFailure,
    void Function(String message, List<BooruConfig> configs)? onSuccess,
    Future<bool> Function(BooruConfigExportData data)? onWillImport,
  }) async {
    if (state == null) return;
    final configRepo = ref.read(booruConfigRepoProvider);

    ref
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

    // ref
    //     .read(booruConfigFileHandlerProvider)
    //     .import(
    //       from: path,
    //     )
    //     .run()
    //     .then(
    //       (value) => value.fold(
    //         (l) => onFailure?.call(l.toString()),
    //         (r) async {
    //           final appVersion = ref.read(appVersionProvider);
    //           if (appVersion.significantlyLowerThan(r.exportVersion)) {
    //             final shouldImport = await showBackwardImportAlertDialog(
    //               context: context,
    //               data: r.exportData,
    //             );

    //             if (shouldImport == null || !shouldImport) return;
    //           }

    //           final willImport = await onWillImport?.call(r);
    //           if (willImport == null || !willImport) return;

    //           await configRepo.clear();
    //           state = await configRepo.addAll(r.data);
    //           onSuccess?.call('Imported successfully', r.data);
    //         },
    //       ),
    //     );
  }

  // export to json
  Future<void> export({
    required String path,
    void Function(String message)? onFailure,
    void Function(String message)? onSuccess,
  }) async {
    if (state == null) return;

    await ref
        .read(booruConfigFileHandlerProvider)
        .export(
          configs: state!,
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
    void Function(String message)? onFailure,
    void Function(String message)? onSuccess,
    required Version? appVersion,
  }) async {
    if (state == null) return;

    BooruConfigIOHandler.exportToClipboard(
      configs: state!,
      onSucceed: () => onSuccess?.call('Copied to clipboard'),
      onError: (e) => onFailure?.call(e),
      appVersion: appVersion,
    );
  }

  Future<void> importClipboard({
    void Function(String message)? onFailure,
    void Function(String message, List<BooruConfig> configs)? onSuccess,
    Future<bool> Function(BooruConfigExportData data)? onWillImport,
  }) async {
    if (state == null) return;

    BooruConfigIOHandler.importFromClipboard().then(
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
}
