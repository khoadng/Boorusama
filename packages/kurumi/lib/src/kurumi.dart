// ignore_for_file: use_full_hex_values_for_flutter_colors

import 'package:material_ui/material_ui.dart';
import 'package:material_ui/material_ui.dart' as material;
import 'package:dynamic_color/dynamic_color.dart';

import 'components/adaptive_sheet.dart' as adaptive_sheet;
import 'components/bottom_sheet.dart' as bottom_sheet;
import 'components/hero.dart' as hero;
import 'components/route_transition.dart' as route_transition;
import 'components/segmented_button.dart' as segmented_button;
import 'components/toast.dart' as toast;
import 'foundation/platform.dart' as platform;
import 'foundation/preferred_layout.dart' as preferred_layout;
import 'theme/semantic_tokens.dart';
import 'theme/theme.dart' as kurumi_theme;
import 'theme/color_schemes.dart';
import 'theme/material_theme.dart';
import 'theme/theme_mode.dart';

/// The callable and value-based API for the Kurumi design language.
///
/// Visual component and theme types remain top-level so they work naturally
/// with Dart's type system. Runtime helpers and shared values live here to
/// keep the public API discoverable under one namespace.
abstract final class Kurumi {
  const Kurumi._();

  static bool isMobilePlatform() => platform.kurumiIsMobilePlatform();

  static bool isDesktopPlatform() => platform.kurumiIsDesktopPlatform();

  static preferred_layout.KurumiPreferredLayout get preferredLayout =>
      preferred_layout.kurumiPreferredLayout;

  /// Returns the semantic colors provided by the nearest [KurumiTheme].
  static KurumiSemanticColors semanticColorsOf(BuildContext context) =>
      kurumi_theme.KurumiTheme.of(context).semanticColors;

  /// Material theme bridge for consumers that still need a complete
  /// [ThemeData] value during migration.
  static ThemeData themeOf(BuildContext context) => Theme.of(context);

  /// Resolves the active palette while preserving Kurumi's built-in theme
  /// modes and dynamic-color behavior.
  static ColorScheme generateColorScheme(
    KurumiThemeMode mode, {
    required bool systemDarkMode,
    ColorScheme? dynamicDarkScheme,
    ColorScheme? dynamicLightScheme,
  }) => switch ((dynamicDarkScheme, dynamicLightScheme)) {
    (final ColorScheme dark, final ColorScheme light) => switch (mode) {
      KurumiThemeMode.light => light.harmonized(),
      KurumiThemeMode.dark => dark.harmonized(),
      KurumiThemeMode.amoledDark => KurumiColorSchemes.amoledDark.copyWith(
        primary: dark.primary,
        onPrimary: dark.onPrimary,
      ),
      KurumiThemeMode.system =>
        systemDarkMode ? dark.harmonized() : light.harmonized(),
    },
    _ => switch (mode) {
      KurumiThemeMode.light => KurumiColorSchemes.light,
      KurumiThemeMode.dark => KurumiColorSchemes.dark,
      KurumiThemeMode.amoledDark => KurumiColorSchemes.amoledDark,
      KurumiThemeMode.system =>
        systemDarkMode ? KurumiColorSchemes.dark : KurumiColorSchemes.light,
    },
  };

  /// Builds the complete Material theme from Kurumi's existing theme rules.
  static ThemeData themeFrom(
    KurumiThemeMode? mode, {
    required ColorScheme colorScheme,
    required bool systemDarkMode,
    bool? isDesktop,
  }) {
    final desktop = isDesktop ?? preferredLayout.isDesktop;

    return switch (mode) {
      KurumiThemeMode.light => KurumiMaterialTheme.lightTheme(
        colorScheme: colorScheme,
        extendedColorScheme: KurumiColorSchemes.lightExtended,
        isDesktop: desktop,
      ),
      KurumiThemeMode.dark => KurumiMaterialTheme.darkTheme(
        colorScheme: colorScheme,
        extendedColorScheme: KurumiColorSchemes.darkExtended,
        isDesktop: desktop,
      ),
      KurumiThemeMode.amoledDark =>
        KurumiMaterialTheme.darkTheme(
          colorScheme: colorScheme,
          extendedColorScheme: KurumiColorSchemes.amoledDarkExtended,
          isDesktop: desktop,
        ).copyWith(
          dividerTheme: const DividerThemeData(
            endIndent: 0,
            indent: 0,
          ),
        ),
      KurumiThemeMode.system =>
        systemDarkMode
            ? KurumiMaterialTheme.darkTheme(
                colorScheme: colorScheme,
                extendedColorScheme: KurumiColorSchemes.darkExtended,
                isDesktop: desktop,
              )
            : KurumiMaterialTheme.lightTheme(
                colorScheme: colorScheme,
                extendedColorScheme: KurumiColorSchemes.lightExtended,
                isDesktop: desktop,
              ),
      null =>
        colorScheme.brightness == Brightness.light
            ? KurumiMaterialTheme.lightTheme(
                colorScheme: colorScheme,
                extendedColorScheme: KurumiColorSchemes.lightExtended,
                isDesktop: desktop,
              )
            : KurumiMaterialTheme.darkTheme(
                colorScheme: colorScheme,
                extendedColorScheme: KurumiColorSchemes.darkExtended,
                isDesktop: desktop,
              ),
    };
  }

  static const bool enableHeroTransition = hero.kKurumiEnableHeroTransition;

  /// Shows Flutter's Material modal bottom sheet without adding an app-level
  /// wrapper. This keeps direct Material call sites behavior-compatible while
  /// still routing the API through Kurumi.
  static Future<T?> showModalBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    Color? backgroundColor,
    String? barrierLabel,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    Color? barrierColor,
    bool isScrollControlled = false,
    double scrollControlDisabledMaxHeightRatio = 0.5625,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    bool? showDragHandle,
    bool useSafeArea = false,
    RouteSettings? routeSettings,
    AnimationController? transitionAnimationController,
    Offset? anchorPoint,
    AnimationStyle? sheetAnimationStyle,
    bool? requestFocus,
  }) => material.showModalBottomSheet<T>(
    context: context,
    builder: builder,
    backgroundColor: backgroundColor,
    barrierLabel: barrierLabel,
    elevation: elevation,
    shape: shape,
    clipBehavior: clipBehavior,
    constraints: constraints,
    barrierColor: barrierColor,
    isScrollControlled: isScrollControlled,
    scrollControlDisabledMaxHeightRatio: scrollControlDisabledMaxHeightRatio,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    showDragHandle: showDragHandle,
    useSafeArea: useSafeArea,
    routeSettings: routeSettings,
    transitionAnimationController: transitionAnimationController,
    anchorPoint: anchorPoint,
    sheetAnimationStyle: sheetAnimationStyle,
    requestFocus: requestFocus,
  );

  /// Shows Kurumi's app-styled modal bottom sheet used by legacy app sheets.
  static Future<T?> showAppModalBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    RouteSettings? routeSettings,
    bool enableDrag = true,
    bool showDragHandle = true,
    bool resizeToAvoidBottomInset = false,
    bool useSafeArea = false,
    Color? backgroundColor,
  }) => bottom_sheet.showKurumiModalBottomSheet<T>(
    context: context,
    builder: builder,
    routeSettings: routeSettings,
    enableDrag: enableDrag,
    showDragHandle: showDragHandle,
    resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    useSafeArea: useSafeArea,
    backgroundColor: backgroundColor,
  );

  static void showSuccessToast(
    BuildContext context,
    String message, {
    Duration? duration,
    Color? backgroundColor,
    TextStyle? textStyle,
  }) => toast.kurumiShowSuccessToast(
    context,
    message,
    duration: duration,
    backgroundColor: backgroundColor,
    textStyle: textStyle,
  );

  static void showErrorToast(
    BuildContext context,
    String message, {
    Duration? duration,
  }) => toast.kurumiShowErrorToast(
    context,
    message,
    duration: duration,
  );

  static void showSimpleSnackBar({
    required BuildContext context,
    required Widget content,
    Duration? duration,
    SnackBarBehavior? behavior,
    SnackBarAction? action,
  }) => toast.kurumiShowSimpleSnackBar(
    context: context,
    content: content,
    duration: duration,
    behavior: behavior,
    action: action,
  );

  static Future<T?> showAdaptiveSheet<T>(
    BuildContext context, {
    required Widget Function(BuildContext context) builder,
    bool expand = false,
    double? width,
    Color? backgroundColor,
    RouteSettings? settings,
  }) => adaptive_sheet.kurumiShowAdaptiveSheet<T>(
    context,
    builder: builder,
    expand: expand,
    width: width,
    backgroundColor: backgroundColor,
    settings: settings,
  );

  static Future<T?> showAdaptiveBottomSheet<T>(
    BuildContext context, {
    required Widget Function(BuildContext context) builder,
    bool expand = false,
    double? height,
    Color? backgroundColor,
    RouteSettings? settings,
  }) => adaptive_sheet.kurumiShowAdaptiveBottomSheet<T>(
    context,
    builder: builder,
    expand: expand,
    height: height,
    backgroundColor: backgroundColor,
    settings: settings,
  );

  static Future<T?> showAppModalBarBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    Color? backgroundColor,
    ShapeBorder? shape,
    Color barrierColor = Colors.black87,
    bool bounce = true,
    bool expand = false,
    Curve? animationCurve,
    bool useRootNavigator = false,
    bool isDismissible = true,
    Duration? duration,
    RouteSettings? settings,
  }) => adaptive_sheet.kurumiShowAppModalBarBottomSheet<T>(
    context: context,
    settings: settings,
    barrierColor: barrierColor,
    duration: duration,
    backgroundColor: backgroundColor,
    shape: shape,
    bounce: bounce,
    expand: expand,
    animationCurve: animationCurve,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    builder: builder,
  );

  static Future<T?> showSideSheetFromLeft<T>({
    required Widget body,
    required BuildContext context,
    double? width,
    String barrierLabel = 'Side Sheet',
    bool barrierDismissible = true,
    Color barrierColor = const Color(0xFF66000000),
    Duration transitionDuration = const Duration(milliseconds: 200),
    RouteSettings? settings,
  }) => adaptive_sheet.kurumiShowSideSheetFromLeft<T>(
    body: body,
    context: context,
    width: width,
    barrierLabel: barrierLabel,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    transitionDuration: transitionDuration,
    settings: settings,
  );

  static Future<T?> showSideSheetFromRight<T>({
    required Widget body,
    required BuildContext context,
    double? width,
    String barrierLabel = 'Side Sheet',
    bool barrierDismissible = true,
    Color barrierColor = const Color(0xFF66000000),
    Duration transitionDuration = const Duration(milliseconds: 200),
    RouteSettings? settings,
  }) => adaptive_sheet.kurumiShowSideSheetFromRight<T>(
    body: body,
    context: context,
    width: width,
    barrierLabel: barrierLabel,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    transitionDuration: transitionDuration,
    settings: settings,
  );

  static RouteTransitionsBuilder parallaxSlideInTransitionBuilder(
    Widget enterWidget,
    Widget oldWidget,
  ) => route_transition.kurumiParallaxSlideInTransitionBuilder(
    enterWidget,
    oldWidget,
  );

  static RouteTransitionsBuilder leftToRightTransitionBuilder() =>
      route_transition.kurumiLeftToRightTransitionBuilder();

  static RouteTransitionsBuilder fadeTransitionBuilder() =>
      route_transition.kurumiFadeTransitionBuilder();

  static double computeSegmentOffset<T>({
    required List<double> sizes,
    required List<T?> items,
    T? current,
  }) => segmented_button.kurumiComputeSegmentOffset<T>(
    sizes: sizes,
    items: items,
    current: current,
  );
}
