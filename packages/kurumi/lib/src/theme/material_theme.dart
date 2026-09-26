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
    useMaterial3: true,
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
    cardTheme: CardThemeData(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    dialogTheme: DialogThemeData(
      surfaceTintColor: Colors.transparent,
      backgroundColor: colorScheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: colorScheme.onSurfaceVariant.withAlpha(100),
    ),
    drawerTheme: DrawerThemeData(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      backgroundColor: colorScheme.surfaceContainerLow,
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: colorScheme.surfaceContainer,
      indicatorColor: colorScheme.secondaryContainer,
      indicatorShape: const StadiumBorder(),
      height: 80,
    ),
    navigationDrawerTheme: NavigationDrawerThemeData(
      backgroundColor: colorScheme.surfaceContainerLow,
      indicatorShape: const StadiumBorder(),
      indicatorColor: colorScheme.secondaryContainer,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: colorScheme.surfaceContainerLow,
      indicatorShape: const StadiumBorder(),
      indicatorColor: colorScheme.secondaryContainer,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        shape: const StadiumBorder(),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      elevation: 2,
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
      fillColor: colorScheme.surfaceContainerHigh,
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 2,
        ),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(
          width: 2,
        ),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
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
      trackHeight: 4,
      thumbColor: colorScheme.primary,
      activeTrackColor: colorScheme.primary,
      inactiveTrackColor: colorScheme.secondaryContainer,
      trackShape: const KurumiCustomSliderTrackShape(),
      thumbShape: const KurumiCustomSliderThumbShape(enabledThumbRadius: 8),
      overlayShape: const KurumiCustomSliderOverlayShape(thumbRadius: 16),
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
