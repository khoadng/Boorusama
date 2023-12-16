// Project imports:
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/foundation/loggers/loggers.dart';

class SettingsRepositoryLoggerInterceptor implements SettingsRepository {
  final SettingsRepository repository;
  final LoggerService _logger;

  SettingsRepositoryLoggerInterceptor(
    this.repository, {
    required LoggerService logger,
  }) : _logger = logger;

  @override
  Future<bool> save(Settings setting) async => repository.save(setting);

  @override
  SettingsOrError load() =>
      repository.load().map((settings) => settings).mapLeft((error) {
        _logger.logE('Settings', "Failed to load settings: $error");
        return error;
      });

  @override
  Future<String> export(Settings settings) => repository.export(settings);

  @override
  Future<void> import(String path) => repository.import(path);
}
