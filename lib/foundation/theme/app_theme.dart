// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';

// Project imports:
import 'colors.dart';
import 'theme_mode.dart';

class AppTheme {
  AppTheme._();

  static ColorScheme defaultColorScheme(ThemeMode mode) => switch (mode) {
        ThemeMode.light => const ColorScheme(
            brightness: Brightness.light,
            background: kBackgroundLightColor,
            onBackground: kOnBackgroundLightColor,
            secondaryContainer: kSecondaryContainerLightColor,
            onSecondaryContainer: kOnSurfaceLightColor,
            tertiaryContainer: Color.fromARGB(255, 220, 220, 220),
            onTertiaryContainer: kOnSurfaceLightColor,
            primary: kPrimaryLightColor,
            onPrimary: kOnPrimaryLightColor,
            secondary: kPrimaryLightColor,
            onSecondary: kOnPrimaryLightColor,
            error: kErrorLightColor,
            onError: kOnErrorLightColor,
            surface: kSurfaceLightColor,
            onSurface: kOnSurfaceLightColor,
          ),
        ThemeMode.dark => const ColorScheme(
            brightness: Brightness.dark,
            background: kBackgroundDarkColor,
            onBackground: kOnBackgroundDarkColor,
            secondaryContainer: kSecondaryContainerDarkColor,
            onSecondaryContainer: kOnSurfaceDarkColor,
            tertiaryContainer: Color.fromARGB(255, 20, 20, 20),
            onTertiaryContainer: kOnSurfaceDarkColor,
            primary: kPrimaryDarkColor,
            onPrimary: kOnPrimaryDarkColor,
            secondary: kPrimaryDarkColor,
            onSecondary: kOnPrimaryDarkColor,
            error: kErrorDarkColor,
            onError: kOnErrorDarkColor,
            surface: kSurfaceDarkColor,
            onSurface: kOnSurfaceDarkColor,
          ),
        ThemeMode.amoledDark => const ColorScheme(
            brightness: Brightness.dark,
            background: kBackgroundAmoledDarkColor,
            onBackground: kOnBackgroundAmoledDarkColor,
            secondaryContainer: kSecondaryContainerAmoledDarkColor,
            onSecondaryContainer: kOnSurfaceAmoledDarkColor,
            tertiaryContainer: Color.fromARGB(255, 20, 20, 20),
            onTertiaryContainer: kOnSurfaceAmoledDarkColor,
            primary: kPrimaryAmoledDarkColor,
            onPrimary: kOnPrimaryAmoledDarkColor,
            secondary: kPrimaryAmoledDarkColor,
            onSecondary: kOnPrimaryAmoledDarkColor,
            error: kErrorAmoledDarkColor,
            onError: kOnErrorAmoledDarkColor,
            surface: kSurfaceAmoledDarkColor,
            onSurface: kOnSurfaceAmoledDarkColor,
          ),
        ThemeMode.system => const ColorScheme(
            brightness: Brightness.dark,
            background: kBackgroundAmoledDarkColor,
            onBackground: kOnBackgroundAmoledDarkColor,
            secondaryContainer: kSecondaryContainerAmoledDarkColor,
            onSecondaryContainer: kOnSurfaceAmoledDarkColor,
            tertiaryContainer: Color.fromARGB(255, 20, 20, 20),
            onTertiaryContainer: kOnSurfaceAmoledDarkColor,
            primary: kPrimaryAmoledDarkColor,
            onPrimary: kOnPrimaryAmoledDarkColor,
            secondary: kPrimaryAmoledDarkColor,
            onSecondary: kOnPrimaryAmoledDarkColor,
            error: kErrorAmoledDarkColor,
            onError: kOnErrorAmoledDarkColor,
            surface: kSurfaceAmoledDarkColor,
            onSurface: kOnSurfaceAmoledDarkColor,
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
        ThemeMode.amoledDark => seed != null
            ? ColorScheme(
                brightness: Brightness.dark,
                background: kBackgroundAmoledDarkColor,
                onBackground: kOnBackgroundAmoledDarkColor,
                secondaryContainer: kSecondaryContainerAmoledDarkColor,
                onSecondaryContainer: kOnSurfaceAmoledDarkColor,
                tertiaryContainer: const Color.fromARGB(255, 20, 20, 20),
                onTertiaryContainer: kOnSurfaceAmoledDarkColor,
                primary: seed.primary,
                onPrimary: seed.onPrimary,
                secondary: kPrimaryAmoledDarkColor,
                onSecondary: kOnPrimaryAmoledDarkColor,
                error: kErrorAmoledDarkColor,
                onError: kOnErrorAmoledDarkColor,
                surface: kSurfaceAmoledDarkColor,
                onSurface: kOnSurfaceAmoledDarkColor,
              )
            : defaultColorScheme(mode),
        ThemeMode.system =>
          seed != null ? seed.harmonized() : defaultColorScheme(mode),
      };

  static ThemeData themeFrom(
    ThemeMode mode, {
    ColorScheme? colorScheme,
    bool useDynamicColor = false,
  }) =>
      switch (mode) {
        ThemeMode.light => lightTheme(
            colorScheme: colorScheme,
            useDynamicColor: useDynamicColor,
          ),
        ThemeMode.dark => darkTheme(
            colorScheme: colorScheme,
            useDynamicColor: useDynamicColor,
          ),
        ThemeMode.amoledDark => darkAmoledTheme(
            colorScheme: colorScheme,
            useDynamicColor: useDynamicColor,
          ),
        ThemeMode.system => darkAmoledTheme(
            colorScheme: colorScheme,
            useDynamicColor: useDynamicColor,
          ),
      };

  static ThemeData lightTheme({
    ColorScheme? colorScheme,
    bool useDynamicColor = false,
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
          cardTheme: CardTheme(
            // color: kSurfaceLightColor,
            color: !useDynamicColor ? kSurfaceLightColor : null,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          dividerTheme: DividerThemeData(
            color: !useDynamicColor ? kHintLightColor.withOpacity(0.4) : null,
            endIndent: 0,
            indent: 0,
          ),
          dialogTheme: DialogTheme(
            backgroundColor: !useDynamicColor ? kSurfaceLightColor : null,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          expansionTileTheme: ExpansionTileThemeData(
            iconColor: !useDynamicColor ? kIconLightColor : null,
          ),
          extensions: const [
            BoorusamaColors(
              videoPlayerBackgroundColor: Colors.white,
              themeMode: ThemeMode.light,
              selectedColor: Colors.grey,
            ),
          ],
          inputDecorationTheme: InputDecorationTheme(
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            fillColor: !useDynamicColor ? kSurfaceLightColor : null,
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                color: kPrimaryLightColor,
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
          brightness: Brightness.light,
          colorScheme: colorScheme,
          scrollbarTheme: ScrollbarThemeData(
            thickness: MaterialStateProperty.all(4),
          ));

  static ThemeData darkTheme({
    ColorScheme? colorScheme,
    bool useDynamicColor = false,
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
          cardTheme: CardTheme(
            color: !useDynamicColor ? kSurfaceDarkColor : null,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          dividerTheme: const DividerThemeData(
            color: kSurfaceDarkColor,
            endIndent: 0,
            indent: 0,
          ),
          dialogTheme: DialogTheme(
            backgroundColor: !useDynamicColor ? kSurfaceDarkColor : null,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          expansionTileTheme: ExpansionTileThemeData(
            iconColor: !useDynamicColor ? kIconDarkColor : null,
          ),
          extensions: const [
            BoorusamaColors(
              videoPlayerBackgroundColor: Colors.black,
              themeMode: ThemeMode.amoledDark,
              selectedColor: kSurfaceDarkColor,
            ),
          ],
          inputDecorationTheme: InputDecorationTheme(
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            fillColor: !useDynamicColor ? kSurfaceDarkColor : null,
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                color: kPrimaryDarkColor,
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
          brightness: Brightness.dark,
          listTileTheme: ListTileThemeData(
            subtitleTextStyle: TextStyle(
              color: !useDynamicColor ? kHintAmoledDarkColor : null,
            ),
          ),
          colorScheme: colorScheme,
          scrollbarTheme: ScrollbarThemeData(
            thickness: MaterialStateProperty.all(4),
          ));

  static ThemeData darkAmoledTheme({
    ColorScheme? colorScheme,
    bool useDynamicColor = false,
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
          cardTheme: CardTheme(
            color: !useDynamicColor ? kSurfaceAmoledDarkColor : null,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          dividerTheme: const DividerThemeData(
            color: kSurfaceAmoledDarkColor,
            endIndent: 0,
            indent: 0,
          ),
          dialogTheme: DialogTheme(
            backgroundColor: !useDynamicColor ? kSurfaceAmoledDarkColor : null,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          expansionTileTheme: ExpansionTileThemeData(
            iconColor: !useDynamicColor ? kIconAmoledDarkColor : null,
          ),
          extensions: const [
            BoorusamaColors(
              videoPlayerBackgroundColor: Colors.black,
              themeMode: ThemeMode.amoledDark,
              selectedColor: kSurfaceAmoledDarkColor,
            ),
          ],
          inputDecorationTheme: InputDecorationTheme(
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            fillColor: !useDynamicColor ? kSurfaceAmoledDarkColor : null,
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                color: kPrimaryAmoledDarkColor,
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
          brightness: Brightness.dark,
          colorScheme: colorScheme,
          scrollbarTheme: ScrollbarThemeData(
            thickness: MaterialStateProperty.all(4),
          ));
}
