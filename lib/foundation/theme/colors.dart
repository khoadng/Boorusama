// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/theme.dart';

const kLightWhiteColor = Color.fromARGB(255, 220, 220, 220);
const kDimWhiteColor = Color.fromARGB(255, 130, 130, 130);

// AMOLED Dark theme
const kPrimaryAmoledDarkColor = Color.fromARGB(255, 86, 99, 233);
const kOnPrimaryAmoledDarkColor = kLightWhiteColor;
const kErrorAmoledDarkColor = Color(0xFFCF6679);
const kOnErrorAmoledDarkColor = kLightWhiteColor;
const kHintAmoledDarkColor = kDimWhiteColor;

// Dark theme
const kPrimaryDarkColor = Color.fromARGB(255, 86, 99, 233);
const kOnPrimaryDarkColor = kLightWhiteColor;
const kErrorDarkColor = Color(0xFFCF6679);
const kOnErrorDarkColor = kLightWhiteColor;
const kIconDarkColor = kLightWhiteColor;

// Light theme
const kPrimaryLightColor = Color.fromARGB(255, 114, 137, 218);
const kOnPrimaryLightColor = Colors.white;
const kOnBackgroundLightColor = Colors.black;
const kOnSurfaceLightColor = Colors.black;
const kErrorLightColor = Color.fromARGB(255, 211, 47, 47);
const kOnErrorLightColor = Colors.white;
const kHintLightColor = Color.fromARGB(255, 79, 86, 96);

class BoorusamaColors extends ThemeExtension<BoorusamaColors> {
  const BoorusamaColors({
    required this.videoPlayerBackgroundColor,
    required this.themeMode,
    required this.selectedColor,
    required this.upvoteColor,
    required this.downvoteColor,
  });

  final Color videoPlayerBackgroundColor;
  final AppThemeMode themeMode;
  final Color selectedColor;
  final Color upvoteColor;
  final Color downvoteColor;

  @override
  ThemeExtension<BoorusamaColors> copyWith({
    Color? videoPlayerBackgroundColor,
    AppThemeMode? themeMode,
    Color? selectedColor,
    Color? upvoteColor,
    Color? downvoteColor,
  }) =>
      BoorusamaColors(
        videoPlayerBackgroundColor:
            videoPlayerBackgroundColor ?? this.videoPlayerBackgroundColor,
        themeMode: themeMode ?? this.themeMode,
        selectedColor: selectedColor ?? this.selectedColor,
        upvoteColor: upvoteColor ?? this.upvoteColor,
        downvoteColor: downvoteColor ?? this.downvoteColor,
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
      upvoteColor: Color.lerp(upvoteColor, other.upvoteColor, t) ?? upvoteColor,
      downvoteColor:
          Color.lerp(downvoteColor, other.downvoteColor, t) ?? downvoteColor,
    );
  }
}

extension DynamicColorX on BuildContext {
  ChipColors? generateChipColors(
    Color? color,
    Settings settings,
  ) =>
      generateChipColorsFromColorScheme(
        color,
        colorScheme,
        settings.enableDynamicColoring,
      );
}

final dynamicColorSupportProvider = Provider<bool>((ref) {
  throw UnimplementedError();
}, name: 'dynamicColorSupportProvider');

final colorSchemeProvider = Provider<ColorScheme>((ref) {
  throw UnimplementedError();
}, name: 'colorSchemeProvider');
