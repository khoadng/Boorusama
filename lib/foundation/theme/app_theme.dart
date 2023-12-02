// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';

// Project imports:
import 'package:boorusama/foundation/theme/theme.dart';

class AppTheme {
  AppTheme._();

  static ColorScheme defaultColorScheme(ThemeMode mode) => switch (mode) {
        ThemeMode.light => const ColorScheme(
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
          ),
        ThemeMode.dark => const ColorScheme(
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
          ),
        _ => const ColorScheme(
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
      };

  static ColorScheme generateFromThemeMode(
    ThemeMode mode, {
    ColorScheme? seed,
  }) =>
      switch (mode) {
        ThemeMode.light =>
          seed != null ? seed.harmonized() : defaultColorScheme(mode),
        ThemeMode.dark =>
          seed != null ? seed.harmonized() : defaultColorScheme(mode),
        _ => seed != null
            ? defaultColorScheme(mode).copyWith(
                primary: seed.primary,
                onPrimary: seed.onPrimary,
              )
            : defaultColorScheme(mode),
      };

  static ThemeData themeFrom(
    ThemeMode mode, {
    required ColorScheme colorScheme,
  }) =>
      switch (mode) {
        ThemeMode.light => lightTheme(
            colorScheme: colorScheme,
          ),
        ThemeMode.dark => darkTheme(
            colorScheme: colorScheme,
          ),
        ThemeMode.amoledDark => darkAmoledTheme(
            colorScheme: colorScheme,
          ),
        ThemeMode.system => darkAmoledTheme(
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
              themeMode: ThemeMode.light,
              selectedColor: Colors.grey,
            ),
          ],
          inputDecorationTheme: const InputDecorationTheme(
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                color: kPrimaryLightColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.all(12),
          ),
          listTileTheme: const ListTileThemeData(
            subtitleTextStyle: TextStyle(
              color: kHintLightColor,
            ),
          ),
          popupMenuTheme: PopupMenuThemeData(
            color: colorScheme.secondaryContainer,
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
              videoPlayerBackgroundColor: Colors.black,
              themeMode: ThemeMode.amoledDark,
              selectedColor: Color.fromARGB(255, 74, 74, 74),
            ),
          ],
          inputDecorationTheme: const InputDecorationTheme(
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                color: kPrimaryDarkColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.all(12),
          ),
          popupMenuTheme: PopupMenuThemeData(
            color: colorScheme.secondaryContainer,
          ),
          brightness: Brightness.dark,
          listTileTheme: ListTileThemeData(
            subtitleTextStyle: TextStyle(
              color: colorScheme.outline,
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
          dividerTheme: const DividerThemeData(
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
              themeMode: ThemeMode.amoledDark,
              selectedColor: Color.fromARGB(255, 50, 50, 50),
            ),
          ],
          inputDecorationTheme: const InputDecorationTheme(
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                color: kPrimaryAmoledDarkColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.all(12),
          ),
          listTileTheme: const ListTileThemeData(
            subtitleTextStyle: TextStyle(
              color: kHintAmoledDarkColor,
            ),
          ),
          popupMenuTheme: PopupMenuThemeData(
            color: colorScheme.secondaryContainer,
          ),
          brightness: Brightness.dark,
          colorScheme: colorScheme,
          scrollbarTheme: ScrollbarThemeData(
            thickness: MaterialStateProperty.all(4),
          ));
}
