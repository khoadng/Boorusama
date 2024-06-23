// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/backups/data_io_handler.dart';
import 'settings_io_handler.dart';

final settingIOHandlerProvider = Provider<SettingsIOHandler>(
  (ref) => SettingsIOHandler(
    handler: DataIOHandler.file(
      version: 1,
      deviceInfo: ref.watch(deviceInfoProvider),
      prefixName: 'boorusama_settings',
    ),
  ),
);
