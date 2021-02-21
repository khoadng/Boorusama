// Project imports:
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting.dart';

abstract class ISettingRepository {
  Future<bool> save(Setting setting);
  Future<Setting> load();
}
