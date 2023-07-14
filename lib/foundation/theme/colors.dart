// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Project imports:
import 'theme_mode.dart';

class BoorusamaColors extends ThemeExtension<BoorusamaColors> {
  const BoorusamaColors({
    required this.videoPlayerBackgroundColor,
    required this.themeMode,
  });

  final Color videoPlayerBackgroundColor;
  final ThemeMode themeMode;

  @override
  ThemeExtension<BoorusamaColors> copyWith({
    Color? videoPlayerBackgroundColor,
    ThemeMode? themeMode,
  }) =>
      BoorusamaColors(
        videoPlayerBackgroundColor:
            videoPlayerBackgroundColor ?? this.videoPlayerBackgroundColor,
        themeMode: themeMode ?? this.themeMode,
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
    );
  }
}
