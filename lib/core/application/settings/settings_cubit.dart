// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/application/settings/settings_state.dart';
import 'package:boorusama/core/domain/settings.dart';

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

mixin SettingsCubitMixin {
  SettingsCubit get settingsCubit;

  Future<void> setGridSize(GridSize size) async {
    final settings =
        await getSettingsOrDefault(settingsCubit.settingRepository);
    await settingsCubit.update(
      settings.copyWith(
        gridSize: size,
      ),
    );
  }

  // set image list
  Future<void> setImageListType(ImageListType imageListType) async {
    final settings =
        await getSettingsOrDefault(settingsCubit.settingRepository);
    await settingsCubit.update(
      settings.copyWith(
        imageListType: imageListType,
      ),
    );
  }

  // set page mode
  Future<void> setPageMode(ContentOrganizationCategory pageMode) async {
    final settings =
        await getSettingsOrDefault(settingsCubit.settingRepository);
    await settingsCubit.update(
      settings.copyWith(
        contentOrganizationCategory: pageMode,
      ),
    );
  }
}
