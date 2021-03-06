// Project imports:
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';

abstract class ISettingRepository {
  Future<bool> save(Settings setting);
  Future<Settings> load();
}
