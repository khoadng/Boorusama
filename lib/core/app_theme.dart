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
          foregroundColor: Colors.black,
        ),
    backgroundColor: const Color.fromARGB(255, 240, 240, 240),
    chipTheme: const ChipThemeData().copyWith(
      backgroundColor: const Color.fromARGB(255, 115, 127, 141),
      disabledColor: const Color.fromARGB(255, 115, 127, 141),
      selectedColor: const Color.fromARGB(255, 114, 137, 218),
    ),
    floatingActionButtonTheme:
        const FloatingActionButtonThemeData(foregroundColor: Colors.white),
    iconTheme: ThemeData.light()
        .iconTheme
        .copyWith(color: const Color.fromARGB(255, 79, 86, 96)),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData()
        .copyWith(backgroundColor: const Color.fromARGB(255, 235, 237, 239)),
  );
  static final darkTheme = ThemeData.dark().copyWith(
    appBarTheme: ThemeData.dark().appBarTheme.copyWith(
          color: ThemeData.dark().scaffoldBackgroundColor,
        ),
    chipTheme: ThemeData.dark().chipTheme.copyWith(
          backgroundColor: const Color.fromARGB(255, 72, 72, 72),
          disabledColor: const Color.fromARGB(255, 72, 72, 72),
          selectedColor: Colors.white,
        ),
    colorScheme: const ColorScheme.dark(
      primary: Color.fromARGB(255, 114, 137, 218),
      secondary: Color.fromARGB(255, 114, 137, 218),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData()
        .copyWith(backgroundColor: Colors.black),
  );

  static final darkAmoledTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.black,
    backgroundColor: const Color.fromARGB(255, 18, 18, 18),
    cardColor: const Color.fromARGB(255, 36, 36, 36),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
      ),
    ),
    floatingActionButtonTheme:
        const FloatingActionButtonThemeData(foregroundColor: Colors.white),
    drawerTheme: ThemeData.dark()
        .drawerTheme
        .copyWith(backgroundColor: const Color.fromARGB(255, 18, 18, 18)),
    appBarTheme: ThemeData.dark().appBarTheme.copyWith(
          color: const Color.fromARGB(255, 18, 18, 18),
        ),
    chipTheme: ThemeData.dark().chipTheme.copyWith(
          backgroundColor: const Color.fromARGB(255, 36, 36, 36),
          disabledColor: const Color.fromARGB(255, 36, 36, 36),
          selectedColor: Colors.white,
        ),
    colorScheme: const ColorScheme.dark(
      primary: Color.fromARGB(255, 86, 99, 233),
      secondary: Color.fromARGB(255, 86, 99, 233),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData()
        .copyWith(backgroundColor: Colors.black),
  );
}
