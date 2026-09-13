import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'extended_color_scheme.dart';
import 'slider_shapes.dart';

class KurumiMaterialTheme {
  KurumiMaterialTheme._();

  static ThemeData lightTheme({
    required ColorScheme colorScheme,
    required KurumiExtendedColorScheme extendedColorScheme,
    bool isDesktop = false,
  }) =>
      defaultTheme(
        colorScheme: colorScheme,
        isDesktop: isDesktop,
      ).copyWith(
        brightness: Brightness.light,
        dividerTheme: DividerThemeData(
          color: colorScheme.outlineVariant.withAlpha(60),
          endIndent: 0,
          indent: 0,
        ),
        extensions: [
          extendedColorScheme,
        ],
      );

  static ThemeData darkTheme({
    required ColorScheme colorScheme,
    required KurumiExtendedColorScheme extendedColorScheme,
    bool isDesktop = false,
  }) =>
      defaultTheme(
        colorScheme: colorScheme,
        isDesktop: isDesktop,
      ).copyWith(
        brightness: Brightness.dark,
        dividerTheme: const DividerThemeData(
          endIndent: 0,
          indent: 0,
        ),
        extensions: [
          extendedColorScheme,
        ],
      );

  static ThemeData defaultTheme({
    required ColorScheme colorScheme,
    bool isDesktop = false,
  }) => ThemeData(
    appBarTheme: AppBarTheme(
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: colorScheme.brightness == Brightness.light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      shadowColor: Colors.transparent,
      titleSpacing: isDesktop ? 4 : null,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 22,
        color: colorScheme.onSurface,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
    ),
    chipTheme: const ChipThemeData(
      shape: StadiumBorder(),
      side: BorderSide.none,
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    dialogTheme: DialogThemeData(
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
    popupMenuTheme: const PopupMenuThemeData(
      surfaceTintColor: Colors.transparent,
    ),
    listTileTheme: ListTileThemeData(
      subtitleTextStyle: TextStyle(
        color: colorScheme.outline,
      ),
    ),
    colorScheme: colorScheme,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
      },
    ),
    scrollbarTheme: ScrollbarThemeData(
      thickness: WidgetStateProperty.all(4),
    ),
    sliderTheme: SliderThemeData(
      trackHeight: 1,
      thumbColor: colorScheme.onSurface,
      trackShape: const KurumiCustomSliderTrackShape(),
      thumbShape: const KurumiCustomSliderThumbShape(),
      overlayShape: const KurumiCustomSliderOverlayShape(),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.disabled)) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.surface.withAlpha(255);
            }
            return colorScheme.onSurface.withAlpha(100);
          }
          if (states.contains(WidgetState.selected)) {
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
    tabBarTheme: TabBarThemeData(
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
