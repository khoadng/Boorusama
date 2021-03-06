// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'settings.dart';

part 'settings_state.freezed.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @required Settings settings,
  }) = _SettingsState;

  factory SettingsState.defaultSettings() => SettingsState(
        settings: Settings.defaultSettings,
      );
}
