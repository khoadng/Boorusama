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
  Future<String> export(Settings settings);
  Future<void> import(String path);
}

Future<int> getSettingsPostsPerPage(SettingsRepository repository) =>
    repository.load().run().then((value) => value.fold(
          (l) => 60,
          (r) => r.postsPerPage,
        ));

Future<Settings> getSettingsOrDefault(SettingsRepository repository) =>
    repository.load().run().then((value) => value.fold(
          (l) => Settings.defaultSettings,
          (r) => r,
        ));

mixin SettingsRepositoryMixin {
  SettingsRepository get settingsRepository;

  Future<int> getPostsPerPage() => getSettingsPostsPerPage(settingsRepository);

  Future<Settings> getOrDefault() => getSettingsOrDefault(settingsRepository);
}
