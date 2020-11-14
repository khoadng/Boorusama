import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeDark());

  @override
  Stream<ThemeState> mapEventToState(
    ThemeEvent event,
  ) async* {
    if (state is ThemeDark) {
      if (event is ThemeChanged) {
        if (event.theme == ThemeMode.light) {
          yield ThemeLight();
        }
      }
    } else if (state is ThemeLight) {
      if (event is ThemeChanged) {
        if (event.theme == ThemeMode.dark) {
          yield ThemeDark();
        }
      }
    } else {
      throw Exception("Unknow theme");
    }
  }
}
