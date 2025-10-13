// Flutter imports:
import 'package:flutter/painting.dart';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../types.dart';

class NoteFontSize extends Equatable {
  const NoteFontSize._(this.value);
  const NoteFontSize.fixed(this.value);

  factory NoteFontSize.calculate({
    required String text,
    required NoteCoordinate coordinate,
  }) {
    final size = coordinate.getSize();
    final availableWidth = size.width - padding * 2;
    final availableHeight = size.height - padding * 2;

    if (availableWidth <= 0 || availableHeight <= 0 || text.isEmpty) {
      return const NoteFontSize._(minValue);
    }

    var low = minValue;
    var high = maxValue;
    var bestFontSize = minValue;

    while (low <= high) {
      final mid = (low + high) / 2;

      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(fontSize: mid),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout(maxWidth: availableWidth);

      if (textPainter.width <= availableWidth &&
          textPainter.height <= availableHeight) {
        bestFontSize = mid;
        low = mid + 0.5;
      } else {
        high = mid - 0.5;
      }
    }

    return NoteFontSize._(bestFontSize);
  }

  static const minValue = 6.0;
  static const maxValue = 32.0;
  static const padding = 2.0;

  final double value;

  @override
  List<Object?> get props => [value];
}
