// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shelf/shelf.dart' as shelf;

// Project imports:
import '../../../foundation/info/package_info.dart';
import '../../config_widgets/website_logo.dart';
import '../../configs/config/types.dart';
import '../../configs/manage/providers.dart';
import '../../settings/providers.dart';
import '../../widgets/reboot.dart';
import '../preparation/preparation_pipeline.dart';
import '../sync/strategies/booru_config_merge.dart';
import '../sync/types.dart';
import '../types/backup_data_source.dart';
import '../types/types.dart';
import '../utils/json_handler.dart';
import '../widgets/backup_restore_tile.dart';
import '../widgets/import_booru_configs_alert_dialog.dart';
import 'json_source.dart';

class BooruConfigExportData {
  BooruConfigExportData({
    required this.data,
    required this.exportData,
  });

  int get version => exportData.version;
  DateTime? get exportDate => exportData.exportDate;
  Version? get exportVersion => exportData.exportVersion;
  final List<BooruConfig> data;
  final ExportDataPayload exportData;
}

Future<bool?> showImportBooruConfigsAlertDialog(
  BuildContext context, {
  required BooruConfigExportData data,
}) {
  return showDialog<bool>(
    context: context,
    routeSettings: const RouteSettings(name: 'booru_import_overwrite_alert'),
    builder: (context) => ImportBooruConfigsAlertDialog(data: data),
  );
}

const kBooruConfigsExporterImporterVersion = 1;

class BooruConfigsBackupSource extends JsonBackupSource<List<BooruConfig>> {
  BooruConfigsBackupSource(this._ref)
    : super(
        id: 'profiles',
        priority: 99999, // Lowest priority - show last
        version: kBooruConfigsExporterImporterVersion,
        appVersion: _ref.read(appVersionProvider),
        dataGetter: () async => _ref.read(booruConfigProvider),
        executor: (configs, uiContext) async {
          final configRepo = _ref.read(booruConfigRepoProvider);
          await configRepo.clear();
          final newConfigs = await configRepo.addAll(configs);

          final firstConfig = newConfigs.firstOrNull;

          if (uiContext != null && uiContext.mounted && firstConfig != null) {
            Reboot.start(
              uiContext,
              RebootData(
                config: firstConfig,
                configs: newConfigs,
                settings: _ref.read(settingsProvider),
              ),
            );
          }
        },
        handler: ListHandler<BooruConfig>(
          parser: BooruConfig.fromJson,
          encoder: (config) => config.toJson(),
        ),
        extraSteps: [
          _BooruConfigValidationStep(),
          _BooruConfigConfirmationStep(_ref),
        ],
        ref: _ref,
      );

  final Ref _ref;
  final _mergeStrategy = BooruConfigMergeStrategy();

  @override
  SyncCapability<BooruConfig> get syncCapability => SyncCapability<BooruConfig>(
    mergeStrategy: _mergeStrategy,
    handlePush: _handlePush,
    getUniqueIdFromJson: _mergeStrategy.getUniqueIdFromJson,
    importResolved: _importResolved,
  );

  Future<void> _importResolved(List<Map<String, dynamic>> data) async {
    if (data.isEmpty) return;

    final configRepo = _ref.read(booruConfigRepoProvider);
    final localConfigs = await dataGetter();

    final resolvedConfigs = data.map((e) => BooruConfig.fromJson(e)).toList();

    // Build set of resolved unique IDs
    final resolvedIds = resolvedConfigs
        .map((c) => BooruConfigUniqueId.fromConfig(c))
        .toSet();

    // Remove local configs that will be replaced
    final toRemove = localConfigs.where(
      (local) => resolvedIds.contains(BooruConfigUniqueId.fromConfig(local)),
    );
    for (final config in toRemove) {
      await configRepo.remove(config);
    }

    // Add all resolved configs
    await configRepo.addAll(resolvedConfigs);
  }

  Future<SyncStats> _handlePush(shelf.Request request) async {
    final body = await request.readAsString();
    final json = jsonDecode(body);

    final remoteData = switch (json) {
      {'data': final List<dynamic> data} => data,
      final List<dynamic> data => data,
      _ => <dynamic>[],
    };

    final remoteItems = remoteData
        .map((e) => BooruConfig.fromJson(e as Map<String, dynamic>))
        .toList();
    final localItems = await dataGetter();
    final result = _mergeStrategy.merge(localItems, remoteItems);

    final newItems = result.merged
        .where(
          (item) => !localItems.any(
            (l) =>
                BooruConfigUniqueId.fromConfig(l) ==
                BooruConfigUniqueId.fromConfig(item),
          ),
        )
        .toList();

    if (newItems.isNotEmpty) {
      final configRepo = _ref.read(booruConfigRepoProvider);
      await configRepo.addAll(newItems);
    }

    return result.stats;
  }

  @override
  String get displayName => 'Booru profiles';

  @override
  Widget buildTile(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final configs = ref.watch(booruConfigProvider);
        final first5Configs = configs.take(5).toList();

        return DefaultBackupTile(
          source: this,
          title: 'Booru profiles',
          icon: Symbols.settings,
          subtitle: '${configs.length} profiles',
          extra: first5Configs.isNotEmpty
              ? [
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...first5Configs.map(
                        (e) => ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: ConfigAwareWebsiteLogo.fromConfig(e.auth),
                        ),
                      ),
                      if (first5Configs.length < configs.length)
                        Text(
                          '+${configs.length - first5Configs.length}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ]
              : null,
        );
      },
    );
  }
}

// Custom validation step for booru configs
class _BooruConfigValidationStep extends PreparationStep<List<BooruConfig>> {
  @override
  Future<PreparationContext<List<BooruConfig>>> execute(
    PreparationContext<List<BooruConfig>> context,
    BuildContext? uiContext,
  ) async {
    final configs = context.parsedData;

    // Validate that we have at least one config
    if (configs.isEmpty) {
      throw Exception('No booru profiles found in backup data');
    }

    // Validate config structure
    for (final config in configs) {
      if (config.name.isEmpty || config.url.isEmpty) {
        throw Exception('Invalid booru profile data: missing name or URL');
      }
    }

    return context;
  }
}

// Custom confirmation step for booru configs
class _BooruConfigConfirmationStep extends PreparationStep<List<BooruConfig>> {
  const _BooruConfigConfirmationStep(this.ref);

  final Ref ref;

  @override
  Future<PreparationContext<List<BooruConfig>>> execute(
    PreparationContext<List<BooruConfig>> context,
    BuildContext? uiContext,
  ) async {
    // Skip confirmation if no UI context (headless operation)
    if (uiContext?.mounted != true) return context;

    final existingConfigs = ref.read(booruConfigProvider);

    // Skip confirmation if no existing configs
    if (existingConfigs.isEmpty) return context;

    final exportData = BooruConfigExportData(
      data: context.parsedData,
      exportData: context.metadata,
    );

    await requireUIConfirmation(
      uiContext,
      (context) => showImportBooruConfigsAlertDialog(context, data: exportData),
    );

    return context;
  }
}
