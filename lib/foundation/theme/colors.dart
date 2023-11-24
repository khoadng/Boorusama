// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/theme/theme_utils.dart';
import 'theme_mode.dart';

const kLightWhiteColor = Color.fromARGB(255, 220, 220, 220);
const kDimWhiteColor = Color.fromARGB(255, 130, 130, 130);

// AMOLED Dark theme
const kPrimaryAmoledDarkColor = Color.fromARGB(255, 86, 99, 233);
const kOnPrimaryAmoledDarkColor = kLightWhiteColor;
const kBackgroundAmoledDarkColor = Colors.black;
const kOnBackgroundAmoledDarkColor = kLightWhiteColor;
const kSecondaryContainerAmoledDarkColor = Color.fromARGB(255, 50, 50, 50);
const kSurfaceAmoledDarkColor = Color.fromARGB(255, 40, 40, 40);
const kOnSurfaceAmoledDarkColor = kLightWhiteColor;
const kErrorAmoledDarkColor = Color(0xFFCF6679);
const kOnErrorAmoledDarkColor = kLightWhiteColor;
const kIconAmoledDarkColor = kLightWhiteColor;
const kHintAmoledDarkColor = kDimWhiteColor;

// Dark theme
const kPrimaryDarkColor = Color.fromARGB(255, 86, 99, 233);
const kOnPrimaryDarkColor = kLightWhiteColor;
const kBackgroundDarkColor = Color.fromARGB(255, 32, 32, 32);
const kOnBackgroundDarkColor = kLightWhiteColor;
const kSecondaryContainerDarkColor = Color.fromARGB(255, 65, 65, 65);
const kSurfaceDarkColor = Color.fromARGB(255, 50, 50, 50);
const kOnSurfaceDarkColor = kLightWhiteColor;
const kErrorDarkColor = Color(0xFFCF6679);
const kOnErrorDarkColor = kLightWhiteColor;
const kIconDarkColor = kLightWhiteColor;

// Light theme
const kPrimaryLightColor = Color.fromARGB(255, 114, 137, 218);
const kOnPrimaryLightColor = Colors.white;
const kBackgroundLightColor = Color.fromARGB(255, 242, 242, 242);
const kOnBackgroundLightColor = Colors.black;
const kSecondaryContainerLightColor = Color.fromARGB(255, 225, 227, 229);
const kSurfaceLightColor = Colors.white;
const kOnSurfaceLightColor = Colors.black;
const kErrorLightColor = Color.fromARGB(255, 211, 47, 47);
const kOnErrorLightColor = Colors.white;
const kIconLightColor = Color.fromARGB(255, 79, 86, 96);
const kHintLightColor = Color.fromARGB(255, 79, 86, 96);

class BoorusamaColors extends ThemeExtension<BoorusamaColors> {
  const BoorusamaColors({
    required this.videoPlayerBackgroundColor,
    required this.themeMode,
    required this.selectedColor,
  });

  final Color videoPlayerBackgroundColor;
  final ThemeMode themeMode;
  final Color selectedColor;

  @override
  ThemeExtension<BoorusamaColors> copyWith({
    Color? videoPlayerBackgroundColor,
    ThemeMode? themeMode,
    Color? selectedColor,
  }) =>
      BoorusamaColors(
        videoPlayerBackgroundColor:
            videoPlayerBackgroundColor ?? this.videoPlayerBackgroundColor,
        themeMode: themeMode ?? this.themeMode,
        selectedColor: selectedColor ?? this.selectedColor,
      );

  @override
  ThemeExtension<BoorusamaColors> lerp(
    covariant ThemeExtension<BoorusamaColors>? other,
    double t,
  ) {
    if (other is! BoorusamaColors) return this;

    return BoorusamaColors(
      videoPlayerBackgroundColor: Color.lerp(
            videoPlayerBackgroundColor,
            other.videoPlayerBackgroundColor,
            t,
          ) ??
          videoPlayerBackgroundColor,
      themeMode: other.themeMode,
      selectedColor:
          Color.lerp(selectedColor, other.selectedColor, t) ?? selectedColor,
    );
  }
}

extension DynamicColorX on BuildContext {
  ChipColors? generateChipColors(
    Color? color,
    Settings settings,
  ) =>
      generateChipColorsFromColorScheme(color, settings, colorScheme);
}

final colorSchemeProvider = Provider<ColorScheme>((ref) {
  throw UnimplementedError();
});

final dynamicColorSupportProvider = Provider<bool>((ref) {
  throw UnimplementedError();
});
