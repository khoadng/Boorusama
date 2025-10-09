// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';

class NoteImage extends Equatable {
  const NoteImage({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  double get aspectRatio => width / height;

  Size get size => Size(width, height);

  Offset widgetToImageCoordinates(Offset widgetPosition, Size widgetSize) {
    final scaleX = width / widgetSize.width;
    final scaleY = height / widgetSize.height;

    return Offset(
      widgetPosition.dx * scaleX,
      widgetPosition.dy * scaleY,
    );
  }

  @override
  List<Object?> get props => [width, height];
}
