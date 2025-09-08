// Project imports:
import '../../../../foundation/loggers.dart';
import '../types/settings.dart';
import '../types/settings_repository.dart';

class SettingsRepositoryLoggerInterceptor implements SettingsRepository {
  SettingsRepositoryLoggerInterceptor(
    this.repository, {
    required Logger logger,
  }) : _logger = logger;
  final SettingsRepository repository;
  final Logger _logger;

  @override
  Future<bool> save(Settings setting) => repository.save(setting);

  @override
  SettingsOrError load() =>
      repository.load().map((settings) => settings).mapLeft((error) {
        _logger.error('Settings', 'Failed to load settings: $error');
        return error;
      });
}
