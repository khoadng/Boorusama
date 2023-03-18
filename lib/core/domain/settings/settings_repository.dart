// Project imports:
import 'package:boorusama/core/domain/settings/settings.dart';

abstract class SettingsRepository {
  Future<bool> save(Settings setting);
  Future<Settings> load();
}
