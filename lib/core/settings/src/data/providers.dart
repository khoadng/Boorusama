// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Project imports:
import '../../../../foundation/loggers.dart';
import '../types/settings_repository.dart';
import 'setting_repository_hive.dart';
import 'settings_repository_logger_interceptor.dart';

final settingsRepoProvider = Provider<SettingsRepository>(
  (ref) => throw UnimplementedError(),
  name: 'settingsRepoProvider',
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
