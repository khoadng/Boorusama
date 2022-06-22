// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../domain/settings/settings.dart';

class SettingsState extends Equatable {
  const SettingsState({
    required this.settings,
  });

  factory SettingsState.defaultSettings() => const SettingsState(
        settings: Settings.defaultSettings,
      );
  final Settings settings;

  @override
  List<Object?> get props => [settings];
}
