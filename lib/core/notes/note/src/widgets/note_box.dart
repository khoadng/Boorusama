// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../types/note_coordinate.dart';
import '../types/note_style.dart';

class NoteBox extends StatelessWidget {
  const NoteBox({
    super.key,
    required this.coordinate,
    required this.style,
  });

  final NoteCoordinate coordinate;
  final NoteStyle? style;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: coordinate.width,
      height: coordinate.height,
      decoration: BoxDecoration(
        color: style?.backgroundColor ?? Colors.white54,
        border: Border.fromBorderSide(
          BorderSide(
            color: style?.borderColor ?? Colors.red,
          ),
        ),
      ),
    );
  }
}
