// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/application/settings/settings_state.dart';
import 'package:boorusama/core/domain/settings/settings.dart';
import 'package:boorusama/core/domain/settings/settings_repository.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required this.settingRepository,
    required Settings settings,
  }) : super(SettingsState(settings: settings));

  final SettingsRepository settingRepository;

  Future<void> update(Settings settings) async {
    final success = await settingRepository.save(settings);
    if (success) {
      emit(
        SettingsState(settings: settings),
      );
    }
  }
}
