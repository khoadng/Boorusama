// Package imports:
import 'package:fpdart/fpdart.dart';

// Project imports:
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
