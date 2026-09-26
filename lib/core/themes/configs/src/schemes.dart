// Package imports:
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../tags/tag/colors.dart';
import '../../colors/types.dart';
import 'color_settings.dart';

// Package imports:

final preDefinedColorSettings = [
  ColorSettings.fromPredefinedScheme(
    'pixel_dark',
    nickname: 'Pixel Dark (Material You)',
  ),
  ColorSettings.fromPredefinedScheme(
    'pixel_light',
    nickname: 'Pixel Light (Material You)',
  ),
  ColorSettings.fromPredefinedScheme(
    'danbooru_dark',
    nickname: 'Dark Blue',
  ),
  ColorSettings.fromPredefinedScheme(
    'danbooru_light',
    nickname: 'Light Blue',
  ),
  ColorSettings.fromPredefinedScheme(
    'green',
    nickname: 'Light Green',
  ),
  ColorSettings.fromPredefinedScheme(
    'dark_green',
    nickname: 'Dark Green',
  ),
  ColorSettings.fromPredefinedScheme(
    'coral_pink',
    nickname: 'Coral Pink',
  ),
  ColorSettings.fromPredefinedScheme(
    'hacker',
    nickname: 'Hacker',
  ),
  ColorSettings.fromPredefinedScheme(
    'cyberpunk',
    nickname: 'Cyberpunk',
  ),
].nonNulls.toList();

final basicColorSettings = [
  ColorSettings.fromBasicScheme(
    'boorusama_light',
    nickname: 'Light',
  ),
  ColorSettings.fromBasicScheme(
    'boorusama_dark',
    nickname: 'Dark',
  ),
  ColorSettings.fromBasicScheme(
    'boorusama_black',
    nickname: 'Midnight',
  ),
  ColorSettings.fromBasicScheme(
    'boorusama_system',
    nickname: 'System',
    followSystemDarkMode: true,
  ),
].nonNulls.toList();

ColorScheme getSchemeFromBasic(
  String? name, {
  required bool systemDarkMode,
  required ColorScheme? dynamicLightScheme,
  required ColorScheme? dynamicDarkScheme,
  required bool enableDynamicColoring,
  required bool? followSystemDarkMode,
}) {
  final mode = (followSystemDarkMode ?? false)
      ? KurumiThemeMode.system
      : switch (name) {
          'boorusama_light' => KurumiThemeMode.light,
          'boorusama_dark' => KurumiThemeMode.dark,
          'boorusama_black' => KurumiThemeMode.amoledDark,
          _ => KurumiThemeMode.amoledDark,
        };

  final (dark, light) = enableDynamicColoring
      ? dynamicLightScheme != null && dynamicDarkScheme != null
            ? (dynamicDarkScheme, dynamicLightScheme)
            : (null, null)
      : (null, null);

  return Kurumi.generateColorScheme(
    mode,
    systemDarkMode: systemDarkMode,
    dynamicLightScheme: light,
    dynamicDarkScheme: dark,
  );
}

ColorScheme? getSchemeFromPredefined(String? name) {
  return switch (name) {
    'pixel_dark' => KurumiPresetColorSchemes.pixelDark,
    'pixel_light' => KurumiPresetColorSchemes.pixelLight,
    'danbooru_dark' => KurumiPresetColorSchemes.danbooruDark,
    'danbooru_light' => KurumiPresetColorSchemes.danbooruLight,
    'green' => KurumiPresetColorSchemes.green,
    'dark_green' => KurumiPresetColorSchemes.darkGreen,
    'coral_pink' => KurumiPresetColorSchemes.coralPink,
    'hacker' => KurumiPresetColorSchemes.hacker,
    'cyberpunk' => KurumiPresetColorSchemes.cyberpunk,
    _ => null,
  };
}

TagColors? getTagColorsFromPredefined(String name, Brightness? brightness) {
  return switch (name) {
    'green' => const TagColors(
      general: Color(0xff000198),
      artist: Color(0xffaa0101),
      character: Color(0xff01aa01),
      copyright: Color(0xffab00ab),
      meta: Color(0xfffe8900),
    ),
    'dark_green' => const TagColors(
      general: Color(0xffb0e0b0),
      artist: Color(0xffeea0a1),
      character: Color(0xfff1f1a0),
      copyright: Color(0xffeea0ee),
      meta: Color(0xff8ed8ec),
    ),
    'coral_pink' => const TagColors(
      general: Color(0xffe36d5e),
      artist: Color(0xffcaca05),
      character: Color(0xff2b9122),
      copyright: Color(0xffdc00dc),
      meta: Color(0xfffe1e1e),
    ),
    _ => null,
  };
}

TagColors? getTagColorsFromColorSettings(ColorSettings? colorSettings) {
  final settings = colorSettings;
  if (settings == null) return null;

  return switch (settings.schemeType) {
    SchemeType.builtIn => getTagColorsFromPredefined(
      settings.name,
      settings.colorScheme?.brightness,
    ),
    _ => null,
  };
}

ColorScheme? getSchemeFromColorSettings(
  ColorSettings? colorSettings, {
  required ColorScheme? dynamicLightScheme,
  required ColorScheme? dynamicDarkScheme,
  required bool systemDarkMode,
}) {
  final settings = colorSettings;
  if (settings == null) return null;

  return switch (settings.schemeType) {
    SchemeType.basic => getSchemeFromBasic(
      settings.name,
      systemDarkMode: systemDarkMode,
      dynamicLightScheme: dynamicLightScheme,
      dynamicDarkScheme: dynamicDarkScheme,
      enableDynamicColoring: settings.enableDynamicColoring,
      followSystemDarkMode: settings.followSystemDarkMode,
    ),
    SchemeType.builtIn => getSchemeFromPredefined(settings.name),
    SchemeType.accent => () {
      final accentColor = settings.name;
      final color = ColorUtils.hexToColor(accentColor);

      if (color == null) return null;

      return ColorScheme.fromSeed(
        seedColor: color,
        brightness: settings.brightness ?? Brightness.dark,
        dynamicSchemeVariant:
            settings.dynamicSchemeVariant ?? DynamicSchemeVariant.tonalSpot,
      );
    }(),
    _ => colorSettings?.colorScheme,
  };
}
