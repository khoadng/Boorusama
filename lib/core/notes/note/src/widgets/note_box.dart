// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../rendering/polygon_note_painter.dart';
import '../types/note.dart';
import '../types/note_coordinate.dart';
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
    return switch (note.coordinate) {
      RectangleNoteCoordinate(
        :final width,
        :final height,
      ) =>
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: _buildBackgroundColor(),
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
              child: _InlineText(
                note: note,
                style: style,
                displayMode: displayMode,
              ),
            ),
          },
        ),
      final PolygonNoteCoordinate polyCoord => Builder(
        builder: (context) {
          final relativePoints = polyCoord.getRelativePoints();
          final size = note.coordinate.getSize();

          return SizedBox(
            width: size.width,
            height: size.height,
            child: CustomPaint(
              painter: PolygonNotePainter(
                points: relativePoints,
                borderColor: style?.borderColor ?? Colors.red,
                backgroundColor: _buildBackgroundColor(),
              ),
              child: switch (displayMode) {
                NoteDisplayMode.box || null => const SizedBox.shrink(),
                NoteDisplayMode.inlineHorizontal ||
                NoteDisplayMode.inlineVertical => ClipPath(
                  clipper: _PolygonClipper(points: relativePoints),
                  child: _InlineText(
                    note: note,
                    style: style,
                    displayMode: displayMode,
                  ),
                ),
              },
            ),
          );
        },
      ),
    };
  }

  Color _buildBackgroundColor() {
    return switch (displayMode) {
      NoteDisplayMode.box || null => style?.backgroundColor ?? Colors.white54,
      NoteDisplayMode.inlineHorizontal ||
      NoteDisplayMode.inlineVertical => Colors.white,
    };
  }
}

class _InlineText extends StatefulWidget {
  const _InlineText({
    required this.note,
    required this.style,
    required this.displayMode,
  });

  final Note note;
  final NoteStyle? style;
  final NoteDisplayMode? displayMode;

  @override
  State<_InlineText> createState() => _InlineTextState();
}

class _InlineTextState extends State<_InlineText> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      widget.note.strippedContent,
      style: TextStyle(
        fontSize: widget.note.fontSize?.value,
        color: widget.style?.foregroundColor ?? Colors.black,
        backgroundColor: widget.style?.backgroundColor ?? Colors.white,
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(1),
      child: switch (widget.displayMode) {
        NoteDisplayMode.inlineVertical => RotatedBox(
          quarterTurns: 1,
          child: Scrollbar(
            thumbVisibility: true,
            controller: _scrollController,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: textWidget,
            ),
          ),
        ),
        _ => Scrollbar(
          thumbVisibility: true,
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: textWidget,
          ),
        ),
      },
    );
  }
}

class _PolygonClipper extends CustomClipper<Path> {
  _PolygonClipper({required this.points});

  final List<Offset> points;

  @override
  Path getClip(Size size) {
    if (points.isEmpty) return Path();
    return Path()..addPolygon(points, true);
  }

  @override
  bool shouldReclip(_PolygonClipper oldClipper) => points != oldClipper.points;
}
