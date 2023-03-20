// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/settings/settings_repository.dart';

class CurrentBooruRepositorySettings implements CurrentUserBooruRepository {
  CurrentBooruRepositorySettings(
    this.settingsRepository,
    this.userBooruRepository,
  );

  final SettingsRepository settingsRepository;
  final UserBooruRepository userBooruRepository;

  @override
  Future<UserBooru?> get() async {
    final settings = await settingsRepository.load();
    final userBoorus = await userBooruRepository.getAll();

    return userBoorus
        .firstWhereOrNull((e) => e.id == settings.currentUserBooruId);
  }
}
