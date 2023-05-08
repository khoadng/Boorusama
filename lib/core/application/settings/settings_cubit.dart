// Package imports:
import 'package:boorusama/core/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/application/settings/settings_state.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required this.settingRepository,
    required Settings settings,
  }) : super(SettingsState(settings: settings));

  final SettingsRepository settingRepository;

  Future<void> update(
    Settings settings, {
    void Function(Settings settings)? onSuccess,
  }) async {
    final success = await settingRepository.save(settings);
    if (success) {
      onSuccess?.call(settings);
      emit(
        SettingsState(settings: settings),
      );
    }
  }
}

extension SettingsCubitRiverpodX on SettingsCubit {
  Future<void> updateAndSyncWithRiverpod(
    Settings settings,
    WidgetRef ref,
  ) =>
      update(
        settings,
        onSuccess: (settings) {
          ref.read(settingsProvider.notifier).updateSettings(settings);
        },
      );
}
