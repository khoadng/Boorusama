// Project imports:
import 'package:boorusama/boorus/danbooru/domain/settings/settings.dart';

abstract class SettingRepository {
  Future<bool> save(Settings setting);
  Future<Settings> load();
}
