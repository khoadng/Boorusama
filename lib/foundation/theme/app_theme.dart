// Flutter imports:
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart' hide ThemeMode;

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
        ThemeMode.amoledDark =>
          seed != null ? seed.harmonized() : defaultColorScheme(mode),
        ThemeMode.system =>
          seed != null ? seed.harmonized() : defaultColorScheme(mode),
      };

  static ThemeData themeFrom(
    ThemeMode mode, {
    ColorScheme? colorScheme,
    bool useDynamicColor = false,
  }) =>
      switch (mode) {
        ThemeMode.light => lightTheme(colorScheme: colorScheme),
        ThemeMode.dark => darkTheme(colorScheme: colorScheme),
        ThemeMode.amoledDark => darkAmoledTheme(colorScheme: colorScheme),
        ThemeMode.system => darkAmoledTheme(colorScheme: colorScheme),
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
        cardTheme: const CardTheme(
          color: kSurfaceLightColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: kSurfaceLightColor,
          endIndent: 0,
          indent: 0,
        ),
        dialogTheme: const DialogTheme(
          backgroundColor: kSurfaceLightColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        expansionTileTheme: const ExpansionTileThemeData(
          iconColor: kIconLightColor,
        ),
        extensions: const [
          BoorusamaColors(
            videoPlayerBackgroundColor: Colors.white,
            themeMode: ThemeMode.light,
            selectedColor: Colors.grey,
          ),
        ],
        iconTheme: const IconThemeData(
          color: kIconLightColor,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          filled: true,
          fillColor: kSurfaceLightColor,
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
        brightness: Brightness.light,
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            textStyle: MaterialStateProperty.all<TextStyle>(
              const TextStyle(
                fontSize: 13,
              ),
            ),
            visualDensity: VisualDensity.compact,
          ),
        ),
        colorScheme: colorScheme,
      );

  static ThemeData darkTheme({
    ColorScheme? colorScheme,
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
          color: kSurfaceDarkColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: kSurfaceDarkColor,
          endIndent: 0,
          indent: 0,
        ),
        dialogTheme: const DialogTheme(
          backgroundColor: kSurfaceDarkColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        expansionTileTheme: const ExpansionTileThemeData(
          iconColor: kIconDarkColor,
        ),
        extensions: const [
          BoorusamaColors(
            videoPlayerBackgroundColor: Colors.black,
            themeMode: ThemeMode.amoledDark,
            selectedColor: kSurfaceDarkColor,
          ),
        ],
        iconTheme: const IconThemeData(
          color: kIconDarkColor,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          filled: true,
          fillColor: kSurfaceDarkColor,
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
        brightness: Brightness.dark,
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            textStyle: MaterialStateProperty.all<TextStyle>(
              const TextStyle(
                fontSize: 13,
              ),
            ),
            visualDensity: VisualDensity.compact,
          ),
        ),
        colorScheme: colorScheme,
      );

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
        dividerTheme: DividerThemeData(
          color: !useDynamicColor ? kSurfaceAmoledDarkColor : null,
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
        iconTheme: IconThemeData(
          color: !useDynamicColor ? kIconAmoledDarkColor : null,
        ),
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
        brightness: Brightness.dark,
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            textStyle: MaterialStateProperty.all<TextStyle>(
              const TextStyle(
                fontSize: 13,
              ),
            ),
            visualDensity: VisualDensity.compact,
          ),
        ),
        colorScheme: colorScheme,
      );
}
