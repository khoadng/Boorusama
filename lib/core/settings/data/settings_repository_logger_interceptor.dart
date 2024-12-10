// Project imports:
import '../../foundation/loggers.dart';
import '../settings.dart';
import 'settings_repository.dart';

class SettingsRepositoryLoggerInterceptor implements SettingsRepository {
  SettingsRepositoryLoggerInterceptor(
    this.repository, {
    required Logger logger,
  }) : _logger = logger;
  final SettingsRepository repository;
  final Logger _logger;

  @override
  Future<bool> save(Settings setting) async => repository.save(setting);

  @override
  SettingsOrError load() =>
      repository.load().map((settings) => settings).mapLeft((error) {
        _logger.logE('Settings', 'Failed to load settings: $error');
        return error;
      });
}
