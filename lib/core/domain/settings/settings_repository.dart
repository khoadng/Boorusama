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

Future<int> getSettingsPostsPerPage(SettingsRepository repository) =>
    repository.load().run().then((value) => value.fold(
          (l) => 60,
          (r) => r.postsPerPage,
        ));

mixin SettingsRepositoryMixin {
  SettingsRepository get settingsRepository;

  Future<int> getPostsPerPage() => getSettingsPostsPerPage(settingsRepository);
  Future<Settings> getOrDefault() => settingsRepository
      .load()
      .run()
      .then((value) => value.fold((l) => Settings.defaultSettings, (r) => r));
}
