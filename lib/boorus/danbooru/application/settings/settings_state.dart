// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'settings.dart';

class SettingsState {
  const SettingsState({
    required this.settings,
  });
  final Settings settings;

  factory SettingsState.defaultSettings() => SettingsState(
        settings: Settings.defaultSettings,
      );
}
