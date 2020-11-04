import 'package:boorusama/infrastructure/repositories/settings/setting.dart';

abstract class ISettingRepository {
  Future save(Setting setting);
  Future<Setting> load();
}
