import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'theme_state.dart';
part 'theme_state_notifier.freezed.dart';

final themeStateNotifierProvider =
    StateNotifierProvider<ThemeStateNotifier>((ref) {
  return ThemeStateNotifier();
});

class ThemeStateNotifier extends StateNotifier<ThemeState> {
  ThemeStateNotifier() : super(ThemeState.darkMode());

  void changeTheme(ThemeMode theme) {
    if (theme == ThemeMode.dark) {
      state = ThemeState.darkMode();
    } else {
      state = ThemeState.lightMode();
    }
  }
}
