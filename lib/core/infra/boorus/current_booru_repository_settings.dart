// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/settings.dart';

class CurrentBooruRepositorySettings
    with SettingsRepositoryMixin
    implements CurrentBooruConfigRepository {
  CurrentBooruRepositorySettings(
    this.settingsRepository,
    this.userBooruRepository,
  );

  @override
  final SettingsRepository settingsRepository;
  final BooruConfigRepository userBooruRepository;

  @override
  Future<BooruConfig?> get() async {
    final settings = await getOrDefault();
    final userBoorus = await userBooruRepository.getAll();

    return userBoorus
        .firstWhereOrNull((e) => e.id == settings.currentBooruConfigId);
  }
}
