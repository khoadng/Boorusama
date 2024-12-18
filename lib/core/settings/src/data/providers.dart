// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Project imports:
import '../../../backups/data_io_handler.dart';
import '../../../backups/providers.dart';
import '../../../foundation/loggers.dart';
import '../../../info/device_info.dart';
import '../types/settings_repository.dart';
import 'setting_repository_hive.dart';
import 'settings_io_handler.dart';
import 'settings_repository_logger_interceptor.dart';

final settingsRepoProvider = Provider<SettingsRepository>(
  (ref) => throw UnimplementedError(),
  name: 'settingsRepoProvider',
);

final settingIOHandlerProvider = Provider<SettingsIOHandler>(
  (ref) => SettingsIOHandler(
    handler: DataIOHandler.file(
      converter: ref.watch(
        defaultBackupConverterProvider(1),
      ),
      deviceInfo: ref.watch(deviceInfoProvider),
      prefixName: 'boorusama_settings',
    ),
  ),
);

Future<SettingsRepository> createSettingsRepo({
  required Logger logger,
}) async {
  return SettingsRepositoryLoggerInterceptor(
    SettingsRepositoryHive(
      Hive.openBox('settings'),
    ),
    logger: logger,
  );
}
