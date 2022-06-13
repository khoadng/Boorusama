// Flutter imports:
import 'package:flutter/material.dart';

class AppTheme {
  // Private Constructor
  AppTheme._();

  static final lightTheme = ThemeData.light().copyWith(
    colorScheme: const ColorScheme.light(
      primary: Color.fromARGB(255, 114, 137, 218),
      secondary: Color.fromARGB(255, 114, 137, 218),
    ),
    appBarTheme: ThemeData.light().appBarTheme.copyWith(
          color: ThemeData.light().scaffoldBackgroundColor,
        ),
  );
  static final darkTheme = ThemeData.dark().copyWith(
    appBarTheme: ThemeData.dark().appBarTheme.copyWith(
          color: ThemeData.dark().scaffoldBackgroundColor,
        ),
    colorScheme: const ColorScheme.dark(
      primary: Color.fromARGB(255, 114, 137, 218),
      secondary: Color.fromARGB(255, 114, 137, 218),
    ).copyWith(secondary: const Color.fromARGB(255, 114, 137, 218)),
  );
}
