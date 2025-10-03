// Dart imports:
import 'dart:ui';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'tag_colors.dart';

class TagColorOptions extends Equatable {
  const TagColorOptions({
    required this.tagType,
    required this.colors,
  });

  final String? tagType;
  final TagColors colors;

  @override
  List<Object?> get props => [
    tagType,
    colors,
  ];
}

class TagColorsOptions extends Equatable {
  const TagColorsOptions({
    required this.brightness,
  });

  final Brightness brightness;

  @override
  List<Object?> get props => [
    brightness,
  ];
}
