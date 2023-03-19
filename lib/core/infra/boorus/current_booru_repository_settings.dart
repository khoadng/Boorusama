// Project imports:
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/settings/settings_repository.dart';

class CurrentBooruRepositorySettings implements CurrentBooruRepository {
  CurrentBooruRepositorySettings(
    this.settingsRepository,
    this.booruFactory,
  );

  final SettingsRepository settingsRepository;
  final BooruFactory booruFactory;

  @override
  Future<Booru> getCurrentBooru() async {
    final settings = await settingsRepository.load();
    final booru = settings.currentBooru;

    return booruFactory.from(type: booru);
  }
}
