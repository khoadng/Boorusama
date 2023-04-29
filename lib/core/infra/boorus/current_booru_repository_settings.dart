// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/settings.dart';

class CurrentBooruRepositorySettings implements CurrentBooruConfigRepository {
  CurrentBooruRepositorySettings(
    this.settingsRepository,
    this.userBooruRepository,
  );

  final SettingsRepository settingsRepository;
  final BooruConfigRepository userBooruRepository;

  @override
  Future<BooruConfig?> get() async {
    final settings =
        await settingsRepository.load().run().then((value) => value.fold(
              (l) => Settings.defaultSettings,
              (r) => r,
            ));
    final userBoorus = await userBooruRepository.getAll();

    return userBoorus
        .firstWhereOrNull((e) => e.id == settings.currentBooruConfigId);
  }
}
