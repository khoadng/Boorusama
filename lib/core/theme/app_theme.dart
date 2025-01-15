// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';

// Project imports:
import '../foundation/display.dart';
import 'colors.dart';
import 'extended_color_scheme.dart';
import 'grayscale_shades.dart';
import 'slider.dart';
import 'theme_mode.dart';
import 'theme_utils.dart';

const staticLightScheme = ColorScheme(
  brightness: Brightness.light,
  secondaryContainer: GreyscaleShades.gray220,
  onSecondaryContainer: kOnSurfaceLightColor,
  tertiaryContainer: GreyscaleShades.gray220,
  onTertiaryContainer: kOnSurfaceLightColor,
  surfaceContainerLowest: GreyscaleShades.gray226,
  surfaceContainerLow: GreyscaleShades.gray224,
  surfaceContainer: GreyscaleShades.gray220,
  surfaceContainerHigh: GreyscaleShades.gray216,
  surfaceContainerHighest: GreyscaleShades.gray214,
  primary: kPrimaryLightColor,
  onPrimary: kOnPrimaryLightColor,
  secondary: kPrimaryLightColor,
  onSecondary: kOnPrimaryLightColor,
  error: kErrorLightColor,
  onError: kOnErrorLightColor,
  surface: GreyscaleShades.gray242,
  onSurface: kOnSurfaceLightColor,
  outline: GreyscaleShades.gray110,
  outlineVariant: GreyscaleShades.gray60,
);

const staticDarkScheme = ColorScheme(
  brightness: Brightness.dark,
  secondaryContainer: GreyscaleShades.gray52,
  onSecondaryContainer: Colors.white,
  tertiaryContainer: GreyscaleShades.gray48,
  onTertiaryContainer: Colors.white,
  surfaceContainerLowest: GreyscaleShades.gray12,
  surfaceContainerLow: GreyscaleShades.gray32,
  surfaceContainer: GreyscaleShades.gray46,
  surfaceContainerHigh: GreyscaleShades.gray50,
  surfaceContainerHighest: GreyscaleShades.gray54,
  primary: kPrimaryDarkColor,
  onPrimary: kOnPrimaryDarkColor,
  secondary: kPrimaryDarkColor,
  onSecondary: kOnPrimaryDarkColor,
  error: kErrorDarkColor,
  onError: kOnErrorDarkColor,
  surface: GreyscaleShades.gray24,
  onSurface: Colors.white,
  outline: GreyscaleShades.gray160,
  outlineVariant: GreyscaleShades.gray60,
);

const staticBlackScheme = ColorScheme(
  brightness: Brightness.dark,
  secondaryContainer: GreyscaleShades.gray32,
  onSecondaryContainer: Colors.white,
  tertiaryContainer: GreyscaleShades.gray28,
  onTertiaryContainer: Colors.white,
  surfaceContainerLowest: GreyscaleShades.gray8,
  surfaceContainerLow: GreyscaleShades.gray20,
  surfaceContainer: GreyscaleShades.gray32,
  surfaceContainerHigh: GreyscaleShades.gray36,
  surfaceContainerHighest: GreyscaleShades.gray40,
  primary: kPrimaryAmoledDarkColor,
  onPrimary: kOnPrimaryAmoledDarkColor,
  secondary: kPrimaryAmoledDarkColor,
  onSecondary: kOnPrimaryAmoledDarkColor,
  error: kErrorAmoledDarkColor,
  onError: kOnErrorAmoledDarkColor,
  surface: Colors.black,
  onSurface: Colors.white,
  outline: GreyscaleShades.gray120,
  outlineVariant: GreyscaleShades.gray48,
);

const staticLightExtendedScheme = ExtendedColorScheme(
  surfaceContainerOverlay: Colors.black54,
  onSurfaceContainerOverlay: Colors.white,
  surfaceContainerOverlayDim: Color(0xb3000000),
  onSurfaceContainerOverlayDim: Colors.white70,
);

const staticDarkExtendedScheme = ExtendedColorScheme(
  surfaceContainerOverlay: Colors.black54,
  onSurfaceContainerOverlay: Colors.white,
  surfaceContainerOverlayDim: Color(0xb3000000),
  onSurfaceContainerOverlayDim: Colors.white70,
);

const staticBlackExtendedScheme = ExtendedColorScheme(
  surfaceContainerOverlay: Colors.black54,
  onSurfaceContainerOverlay: Colors.white,
  surfaceContainerOverlayDim: Color(0xb3000000),
  onSurfaceContainerOverlayDim: Colors.white70,
);

class AppTheme {
  AppTheme._();

  static ColorScheme generateScheme(
    AppThemeMode mode, {
    required bool systemDarkMode,
    ColorScheme? dynamicDarkScheme,
    ColorScheme? dynamicLightScheme,
  }) =>
      switch ((dynamicDarkScheme, dynamicLightScheme)) {
        (final ColorScheme dark, final ColorScheme light) => switch (mode) {
            AppThemeMode.light => light.harmonized(),
            AppThemeMode.dark => dark.harmonized(),
            AppThemeMode.amoledDark => staticBlackScheme.copyWith(
                primary: dark.primary,
                onPrimary: dark.onPrimary,
              ),
            AppThemeMode.system =>
              systemDarkMode ? dark.harmonized() : light.harmonized(),
          },
        _ => switch (mode) {
            AppThemeMode.light => staticLightScheme,
            AppThemeMode.dark => staticDarkScheme,
            AppThemeMode.amoledDark => staticBlackScheme,
            AppThemeMode.system =>
              systemDarkMode ? staticDarkScheme : staticLightScheme,
          },
      };

  static ThemeData themeFrom(
    AppThemeMode? mode, {
    required ColorScheme colorScheme,
    required bool systemDarkMode,
  }) =>
      switch (mode) {
        AppThemeMode.light => lightTheme(
            colorScheme: colorScheme,
            extendedColorScheme: staticLightExtendedScheme,
          ),
        AppThemeMode.dark => darkTheme(
            colorScheme: colorScheme,
            extendedColorScheme: staticDarkExtendedScheme,
          ),
        AppThemeMode.amoledDark => darkTheme(
            colorScheme: colorScheme,
            extendedColorScheme: staticBlackExtendedScheme,
          ).copyWith(
            dividerTheme: const DividerThemeData(
              endIndent: 0,
              indent: 0,
            ),
          ),
        AppThemeMode.system => systemDarkMode
            ? darkTheme(
                colorScheme: colorScheme,
                extendedColorScheme: staticDarkExtendedScheme,
              )
            : lightTheme(
                colorScheme: colorScheme,
                extendedColorScheme: staticLightExtendedScheme,
              ),
        null => switch (colorScheme.brightness) {
            Brightness.light => lightTheme(
                colorScheme: colorScheme,
                extendedColorScheme: staticLightExtendedScheme,
              ),
            Brightness.dark => darkTheme(
                colorScheme: colorScheme,
                extendedColorScheme: staticDarkExtendedScheme,
              ),
          },
      };

  static ThemeData lightTheme({
    required ColorScheme colorScheme,
    required ExtendedColorScheme extendedColorScheme,
  }) =>
      defaultTheme(colorScheme: colorScheme).copyWith(
        brightness: Brightness.light,
        dividerTheme: DividerThemeData(
          color: colorScheme.outlineVariant.withAlpha(60),
          endIndent: 0,
          indent: 0,
        ),
        extensions: [
          const BoorusamaColors(
            upvoteColor: Colors.redAccent,
            downvoteColor: Colors.blueAccent,
          ),
          extendedColorScheme,
        ],
      );

  static ThemeData darkTheme({
    required ColorScheme colorScheme,
    required ExtendedColorScheme extendedColorScheme,
  }) =>
      defaultTheme(colorScheme: colorScheme).copyWith(
        brightness: Brightness.dark,
        dividerTheme: const DividerThemeData(
          endIndent: 0,
          indent: 0,
        ),
        extensions: [
          const BoorusamaColors(
            upvoteColor: Colors.redAccent,
            downvoteColor: Colors.blueAccent,
          ),
          extendedColorScheme,
        ],
      );

  static ThemeData defaultTheme({
    required ColorScheme colorScheme,
  }) =>
      ThemeData(
        appBarTheme: AppBarTheme(
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          color: Colors.transparent,
          systemOverlayStyle: colorScheme.brightness.isLight
              ? SystemUiOverlayStyle.dark
              : SystemUiOverlayStyle.light,
          shadowColor: Colors.transparent,
          titleSpacing: kPreferredLayout.isDesktop ? 4 : null,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: colorScheme.onSurface,
          ),
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
        dialogTheme: DialogTheme(
          surfaceTintColor: Colors.transparent,
          backgroundColor: colorScheme.surfaceContainer,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          shape: CircleBorder(),
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(
            color: colorScheme.outline,
          ),
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
          labelTextStyle: WidgetStateProperty.all(
            TextStyle(
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ),
        listTileTheme: ListTileThemeData(
          subtitleTextStyle: TextStyle(
            color: colorScheme.outline,
          ),
        ),
        colorScheme: colorScheme,
        scrollbarTheme: ScrollbarThemeData(
          thickness: WidgetStateProperty.all(4),
        ),
        sliderTheme: SliderThemeData(
          trackHeight: 1,
          thumbColor: colorScheme.onSurface,
          trackShape: const CustomSliderTrackShape(),
          thumbShape: const CustomSliderThumbShape(),
          overlayShape: const CustomSliderOverlayShape(),
        ),
        switchTheme: SwitchThemeData(
          // Copy from _SwitchDefaultsM3
          thumbColor: WidgetStateProperty.resolveWith(
            (states) {
              if (states.contains(WidgetState.disabled)) {
                if (states.contains(WidgetState.selected)) {
                  return colorScheme.surface.withAlpha(255);
                }
                return colorScheme.onSurface.withAlpha(100);
              }
              if (states.contains(WidgetState.selected)) {
                // Workaround for when primaryContainer is not provided
                // if (states.contains(WidgetState.pressed)) {
                //   return colorScheme.primaryContainer;
                // }
                // if (states.contains(WidgetState.hovered)) {
                //   return colorScheme.primaryContainer;
                // }
                // if (states.contains(WidgetState.focused)) {
                //   return colorScheme.primaryContainer;
                // }
                return colorScheme.onPrimary;
              }
              if (states.contains(WidgetState.pressed)) {
                return colorScheme.onSurfaceVariant;
              }
              if (states.contains(WidgetState.hovered)) {
                return colorScheme.onSurfaceVariant;
              }
              if (states.contains(WidgetState.focused)) {
                return colorScheme.onSurfaceVariant;
              }
              return colorScheme.outline;
            },
          ),
        ),
        tabBarTheme: TabBarTheme(
          tabAlignment: TabAlignment.start,
          indicatorColor: colorScheme.onSurface,
          labelStyle: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          unselectedLabelStyle: TextStyle(
            color: colorScheme.onSurface.withAlpha(127),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          dividerHeight: 0.1,
        ),
      );
}

extension ColorSchemeAlias on ColorScheme {
  Color get hintColor => outline;
}
