// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';

// Project imports:
import 'package:boorusama/foundation/theme/theme.dart';

class AppTheme {
  AppTheme._();

  static ColorScheme defaultColorScheme(
    AppThemeMode mode, {
    required bool systemDarkMode,
  }) {
    const light = ColorScheme(
      brightness: Brightness.light,
      background: GreyscaleShades.gray242,
      onBackground: kOnBackgroundLightColor,
      secondaryContainer: GreyscaleShades.gray212,
      onSecondaryContainer: kOnSurfaceLightColor,
      tertiaryContainer: GreyscaleShades.gray220,
      onTertiaryContainer: kOnSurfaceLightColor,
      surfaceVariant: GreyscaleShades.gray226,
      primary: kPrimaryLightColor,
      onPrimary: kOnPrimaryLightColor,
      secondary: kPrimaryLightColor,
      onSecondary: kOnPrimaryLightColor,
      error: kErrorLightColor,
      onError: kOnErrorLightColor,
      surface: GreyscaleShades.gray242,
      onSurface: kOnSurfaceLightColor,
    );

    const dark = ColorScheme(
      brightness: Brightness.dark,
      background: GreyscaleShades.gray24,
      onBackground: Colors.white,
      secondaryContainer: GreyscaleShades.gray52,
      onSecondaryContainer: Colors.white,
      tertiaryContainer: GreyscaleShades.gray48,
      onTertiaryContainer: Colors.white,
      surfaceVariant: GreyscaleShades.gray46,
      primary: kPrimaryDarkColor,
      onPrimary: kOnPrimaryDarkColor,
      secondary: kPrimaryDarkColor,
      onSecondary: kOnPrimaryDarkColor,
      error: kErrorDarkColor,
      onError: kOnErrorDarkColor,
      surface: GreyscaleShades.gray24,
      onSurface: Colors.white,
    );

    return switch (mode) {
      AppThemeMode.light => light,
      AppThemeMode.dark => dark,
      AppThemeMode.amoledDark => const ColorScheme(
          brightness: Brightness.dark,
          background: Colors.black,
          onBackground: Colors.white,
          secondaryContainer: GreyscaleShades.gray32,
          onSecondaryContainer: Colors.white,
          tertiaryContainer: GreyscaleShades.gray28,
          onTertiaryContainer: Colors.white,
          surfaceVariant: GreyscaleShades.gray24,
          primary: kPrimaryAmoledDarkColor,
          onPrimary: kOnPrimaryAmoledDarkColor,
          secondary: kPrimaryAmoledDarkColor,
          onSecondary: kOnPrimaryAmoledDarkColor,
          error: kErrorAmoledDarkColor,
          onError: kOnErrorAmoledDarkColor,
          surface: Colors.black,
          onSurface: Colors.white,
          outline: Colors.white,
          outlineVariant: GreyscaleShades.gray60,
        ),
      AppThemeMode.system => systemDarkMode ? dark : light,
    };
  }

  static ColorScheme generateFromThemeMode(
    AppThemeMode mode, {
    ColorScheme? seed,
    required bool systemDarkMode,
  }) {
    final dark = seed != null
        ? seed.harmonized()
        : defaultColorScheme(
            mode,
            systemDarkMode: systemDarkMode,
          );
    final light = seed != null
        ? seed.harmonized()
        : defaultColorScheme(
            mode,
            systemDarkMode: systemDarkMode,
          );

    return switch (mode) {
      AppThemeMode.light => light,
      AppThemeMode.dark => dark,
      AppThemeMode.amoledDark => seed != null
          ? defaultColorScheme(
              mode,
              systemDarkMode: systemDarkMode,
            ).copyWith(
              primary: seed.primary,
              onPrimary: seed.onPrimary,
            )
          : defaultColorScheme(
              mode,
              systemDarkMode: systemDarkMode,
            ),
      AppThemeMode.system => systemDarkMode ? dark : light,
    };
  }

  static ThemeData themeFrom(
    AppThemeMode mode, {
    required ColorScheme colorScheme,
    required bool systemDarkMode,
  }) =>
      switch (mode) {
        AppThemeMode.light => lightTheme(
            colorScheme: colorScheme,
          ),
        AppThemeMode.dark => darkTheme(
            colorScheme: colorScheme,
          ),
        AppThemeMode.amoledDark => darkAmoledTheme(
            colorScheme: colorScheme,
          ),
        AppThemeMode.system => systemDarkMode
            ? darkTheme(
                colorScheme: colorScheme,
              )
            : lightTheme(
                colorScheme: colorScheme,
              ),
      };

  static ThemeData lightTheme({
    required ColorScheme colorScheme,
  }) =>
      ThemeData(
          appBarTheme: const AppBarTheme(
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          chipTheme: const ChipThemeData(
            shape: StadiumBorder(),
            side: BorderSide.none,
          ),
          cardTheme: const CardTheme(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          dividerTheme: DividerThemeData(
            color: colorScheme.outlineVariant.withOpacity(0.25),
            endIndent: 0,
            indent: 0,
          ),
          dialogTheme: const DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          extensions: const [
            BoorusamaColors(
              videoPlayerBackgroundColor: Colors.white,
              themeMode: AppThemeMode.light,
              selectedColor: Colors.grey,
            ),
          ],
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            shape: CircleBorder(),
          ),
          inputDecorationTheme: InputDecorationTheme(
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                width: 2,
              ),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          listTileTheme: const ListTileThemeData(
            subtitleTextStyle: TextStyle(
              color: kHintLightColor,
            ),
          ),
          popupMenuTheme: PopupMenuThemeData(
            color: colorScheme.secondaryContainer,
            labelTextStyle: MaterialStateProperty.all(
              TextStyle(
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          brightness: Brightness.light,
          colorScheme: colorScheme,
          scrollbarTheme: ScrollbarThemeData(
            thickness: MaterialStateProperty.all(4),
          ));

  static ThemeData darkTheme({
    required ColorScheme colorScheme,
  }) =>
      ThemeData(
          appBarTheme: const AppBarTheme(
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          chipTheme: const ChipThemeData(
            shape: StadiumBorder(),
            side: BorderSide.none,
          ),
          cardTheme: const CardTheme(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          dividerTheme: DividerThemeData(
            color: colorScheme.outlineVariant.withOpacity(0.1),
            endIndent: 0,
            indent: 0,
          ),
          dialogTheme: const DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          extensions: const [
            BoorusamaColors(
              videoPlayerBackgroundColor: Colors.black,
              themeMode: AppThemeMode.amoledDark,
              selectedColor: Color.fromARGB(255, 74, 74, 74),
            ),
          ],
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            shape: CircleBorder(),
          ),
          inputDecorationTheme: InputDecorationTheme(
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                width: 2,
              ),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          popupMenuTheme: PopupMenuThemeData(
            color: colorScheme.secondaryContainer,
            labelTextStyle: MaterialStateProperty.all(
              TextStyle(
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          brightness: Brightness.dark,
          listTileTheme: const ListTileThemeData(
            subtitleTextStyle: TextStyle(
              color: kHintAmoledDarkColor,
            ),
          ),
          colorScheme: colorScheme,
          scrollbarTheme: ScrollbarThemeData(
            thickness: MaterialStateProperty.all(4),
          ));

  static ThemeData darkAmoledTheme({
    required ColorScheme colorScheme,
  }) =>
      ThemeData(
          appBarTheme: const AppBarTheme(
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          chipTheme: const ChipThemeData(
            shape: StadiumBorder(),
            side: BorderSide.none,
          ),
          cardTheme: const CardTheme(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          dividerTheme: DividerThemeData(
            color: colorScheme.outlineVariant.withOpacity(0.8),
            endIndent: 0,
            indent: 0,
          ),
          dialogTheme: const DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          extensions: const [
            BoorusamaColors(
              videoPlayerBackgroundColor: Colors.black,
              themeMode: AppThemeMode.amoledDark,
              selectedColor: Color.fromARGB(255, 50, 50, 50),
            ),
          ],
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            shape: CircleBorder(),
          ),
          inputDecorationTheme: InputDecorationTheme(
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                width: 2,
              ),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          listTileTheme: const ListTileThemeData(
            subtitleTextStyle: TextStyle(
              color: kHintAmoledDarkColor,
            ),
          ),
          popupMenuTheme: PopupMenuThemeData(
            color: colorScheme.secondaryContainer,
            labelTextStyle: MaterialStateProperty.all(
              TextStyle(
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          brightness: Brightness.dark,
          colorScheme: colorScheme,
          scrollbarTheme: ScrollbarThemeData(
            thickness: MaterialStateProperty.all(4),
          ));
}
