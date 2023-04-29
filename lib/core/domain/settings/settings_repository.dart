// Project imports:
import 'package:boorusama/functional.dart';
import 'settings.dart';

typedef SettingsOrError = TaskEither<SettingsLoadError, Settings>;

enum SettingsLoadError {
  failedToOpenDatabase,
  tableNotFound,
  invalidJsonFormat,
  failedToMapJsonToSettings,
  unknown,
}

abstract class SettingsRepository {
  Future<bool> save(Settings setting);
  SettingsOrError load();
}
