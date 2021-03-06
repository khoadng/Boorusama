// Package imports:
import 'package:hooks_riverpod/all.dart';
import 'package:meta/meta.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/i_setting_repository.dart';
import 'settings.dart';
import 'settings_state.dart';

final settingsNotifier = StateNotifierProvider<SettingsStateNotifier>((ref) {
  throw UnimplementedError("Override needed");
});

class SettingsStateNotifier extends StateNotifier<SettingsState> {
  SettingsStateNotifier({
    @required this.settingRepository,
    SettingsState setting,
  }) : super(setting ?? SettingsState.defaultSettings());

  final ISettingRepository settingRepository;

  void save(Settings setting) {
    state = state.copyWith(settings: setting);
    settingRepository.save(state.settings);
  }
}
