// Project imports:
import 'settings.dart';

abstract class SettingsRepository {
  Future<bool> save(Settings setting);
  Future<Settings> load();
}
