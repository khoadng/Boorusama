// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as m;

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Copy from Flutter ThemeMode enum
enum ThemeMode {
  system,
  light,
  dark,
  amoledDark,
}

@immutable
class ThemeState extends Equatable {
  const ThemeState({
    required this.theme,
  });

  final ThemeMode theme;

  ThemeState copyWith({ThemeMode? theme}) => ThemeState(
        theme: theme ?? this.theme,
      );

  @override
  List<Object> get props => [theme];
}

@immutable
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
}

class ThemeChanged extends ThemeEvent {
  const ThemeChanged({
    required this.theme,
  });

  final ThemeMode theme;

  @override
  List<Object> get props => [theme];
}

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc({
    required ThemeMode initialTheme,
  }) : super(ThemeState(theme: initialTheme)) {
    on<ThemeChanged>((event, emit) {
      emit(state.copyWith(theme: event.theme));
    });
  }
}

m.ThemeMode mapAppThemeModeToSystemThemeMode(ThemeMode theme) =>
    switch (theme) {
      ThemeMode.system => m.ThemeMode.system,
      ThemeMode.dark => m.ThemeMode.dark,
      ThemeMode.light => m.ThemeMode.light,
      ThemeMode.amoledDark => m.ThemeMode.dark
    };
