// Project imports:
import 'package:boorusama/core/infra/loggers.dart';
import 'package:boorusama/core/settings/settings.dart';

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
}
