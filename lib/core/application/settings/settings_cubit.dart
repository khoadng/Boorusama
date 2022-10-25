// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/application/settings/settings_state.dart';
import 'package:boorusama/core/domain/settings/setting_repository.dart';
import 'package:boorusama/core/domain/settings/settings.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required this.settingRepository,
    required Settings settings,
  }) : super(SettingsState(settings: settings));

  final SettingRepository settingRepository;

  Future<void> update(Settings settings) async {
    final success = await settingRepository.save(settings);
    if (success) {
      emit(
        SettingsState(settings: settings),
      );
    }
  }
}
