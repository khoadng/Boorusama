// Project imports:
import 'package:boorusama/core/domain/settings/settings.dart';

abstract class SettingRepository {
  Future<bool> save(Settings setting);
  Future<Settings> load();
}
