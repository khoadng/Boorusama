// Flutter imports:
import 'package:flutter/material.dart';

class AppTheme {
  // Private Constructor
  AppTheme._();

  static final lightTheme = ThemeData.light().copyWith(
    appBarTheme: ThemeData.light().appBarTheme.copyWith(
          color: ThemeData.light().scaffoldBackgroundColor,
          foregroundColor: Colors.black,
        ),
    cardColor: const Color.fromARGB(255, 235, 235, 235),
    buttonBarTheme: ThemeData.dark()
        .buttonBarTheme
        .copyWith(buttonTextTheme: ButtonTextTheme.normal),
    chipTheme: const ChipThemeData().copyWith(
      backgroundColor: const Color.fromARGB(255, 230, 230, 230),
      disabledColor: const Color.fromARGB(255, 115, 127, 141),
      selectedColor: const Color.fromARGB(255, 0, 0, 0),
      labelStyle:
          const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
      secondaryLabelStyle:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    ),
    floatingActionButtonTheme:
        const FloatingActionButtonThemeData(foregroundColor: Colors.white),
    iconTheme: ThemeData.light()
        .iconTheme
        .copyWith(color: const Color.fromARGB(255, 79, 86, 96)),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData()
        .copyWith(backgroundColor: const Color.fromARGB(255, 225, 227, 229)),
    expansionTileTheme: ThemeData.light().expansionTileTheme.copyWith(
          textColor: Colors.black,
          iconColor: Colors.black,
        ), colorScheme: const ColorScheme.light(
      primary: Color.fromARGB(255, 114, 137, 218),
      secondary: Color.fromARGB(255, 114, 137, 218),
    ).copyWith(background: const Color.fromARGB(255, 240, 240, 240)),
  );
  static final darkTheme = ThemeData.dark().copyWith(
    appBarTheme: ThemeData.dark().appBarTheme.copyWith(
          color: ThemeData.dark().scaffoldBackgroundColor,
        ),
    buttonBarTheme: ThemeData.dark()
        .buttonBarTheme
        .copyWith(buttonTextTheme: ButtonTextTheme.normal),
    chipTheme: ThemeData.dark().chipTheme.copyWith(
          backgroundColor: const Color.fromARGB(255, 72, 72, 72),
          disabledColor: const Color.fromARGB(255, 72, 72, 72),
          selectedColor: Colors.white,
          labelStyle:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          secondaryLabelStyle:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData()
        .copyWith(backgroundColor: Colors.black),
    expansionTileTheme: ThemeData.dark().expansionTileTheme.copyWith(
          textColor: Colors.white,
          iconColor: Colors.white,
        ), colorScheme: const ColorScheme.dark(
      primary: Color.fromARGB(255, 114, 137, 218),
      secondary: Color.fromARGB(255, 114, 137, 218),
    ).copyWith(background: const Color.fromARGB(255, 36, 36, 36)),
  );

  static final darkAmoledTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.black,
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
    buttonBarTheme: ThemeData.dark()
        .buttonBarTheme
        .copyWith(buttonTextTheme: ButtonTextTheme.normal),
    chipTheme: ThemeData.dark().chipTheme.copyWith(
          backgroundColor: const Color.fromARGB(255, 36, 36, 36),
          disabledColor: const Color.fromARGB(255, 36, 36, 36),
          selectedColor: Colors.white,
          labelStyle:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          secondaryLabelStyle:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData()
        .copyWith(backgroundColor: Colors.black),
    expansionTileTheme: ThemeData.dark().expansionTileTheme.copyWith(
          textColor: Colors.white,
          iconColor: Colors.white,
        ), colorScheme: const ColorScheme.dark(
      primary: Color.fromARGB(255, 86, 99, 233),
      secondary: Color.fromARGB(255, 86, 99, 233),
    ).copyWith(background: const Color.fromARGB(255, 18, 18, 18)),
  );
}
