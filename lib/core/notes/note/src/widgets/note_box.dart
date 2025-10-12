// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../types/note.dart';
import '../types/note_display_mode.dart';
import '../types/note_style.dart';

class NoteBox extends StatelessWidget {
  const NoteBox({
    super.key,
    required this.note,
    required this.style,
    this.displayMode,
  });

  final Note note;
  final NoteStyle? style;
  final NoteDisplayMode? displayMode;

  @override
  Widget build(BuildContext context) {
    final (coordinate, content) = (note.coordinate, note.content);

    return Container(
      width: coordinate.width,
      height: coordinate.height,
      decoration: BoxDecoration(
        color: switch (displayMode) {
          NoteDisplayMode.box ||
          null => style?.backgroundColor ?? Colors.white54,
          NoteDisplayMode.inlineHorizontal ||
          NoteDisplayMode.inlineVertical => Colors.white,
        },
        border: Border.fromBorderSide(
          BorderSide(
            color: style?.borderColor ?? Colors.red,
          ),
        ),
      ),
      child: switch (displayMode) {
        NoteDisplayMode.box || null => null,
        NoteDisplayMode.inlineHorizontal ||
        NoteDisplayMode.inlineVertical => ClipRect(
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: _buildInlineText(),
          ),
        ),
      },
    );
  }

  Widget _buildInlineText() {
    final textWidget = Text(
      note.strippedContent,
      style: TextStyle(
        fontSize: note.fontSize?.value,
        color: style?.foregroundColor ?? Colors.black,
        backgroundColor: style?.backgroundColor ?? Colors.white,
      ),
    );

    return switch (displayMode) {
      NoteDisplayMode.inlineVertical => RotatedBox(
        quarterTurns: 1,
        child: textWidget,
      ),
      _ => textWidget,
    };
  }
}
