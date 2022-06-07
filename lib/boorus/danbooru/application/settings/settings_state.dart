// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'settings.dart';

class SettingsState extends Equatable {
  const SettingsState({
    required this.settings,
  });
  final Settings settings;

  factory SettingsState.defaultSettings() => SettingsState(
        settings: Settings.defaultSettings,
      );

  @override
  List<Object?> get props => [settings];
}
