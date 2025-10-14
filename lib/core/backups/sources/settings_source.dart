// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../foundation/info/package_info.dart';
import '../../settings/providers.dart';
import '../../settings/types.dart';
import '../utils/json_handler.dart';
import '../widgets/backup_restore_tile.dart';
import 'json_source.dart';

const kSettingsBackupVersion = 1;

class SettingsBackupSource extends JsonBackupSource<Settings> {
  SettingsBackupSource(Ref ref)
    : super(
        id: 'settings',
        priority: 0,
        version: kSettingsBackupVersion,
        appVersion: ref.read(appVersionProvider),
        dataGetter: () async => ref.read(settingsProvider),
        executor: (settings, _) => ref
            .read(settingsNotifierProvider.notifier)
            .updateSettings(settings),
        handler: SingleHandler<Settings>(
          parser: Settings.fromJson,
          encoder: (settings) => settings.toJson(),
        ),
        ref: ref,
      );

  @override
  String get displayName => 'Settings';

  @override
  Widget buildTile(BuildContext context) {
    return DefaultBackupTile(
      source: this,
      title: 'Settings',
      icon: Symbols.settings,
    );
  }
}
