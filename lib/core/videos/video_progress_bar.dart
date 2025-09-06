// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../foundation/platform.dart';

class DurationRange {
  const DurationRange({
    required this.start,
    required this.end,
  });

  final Duration start;
  final Duration end;

  double startFraction(Duration duration) {
    if (duration.inMilliseconds == 0) return 0.0;
    return start.inMilliseconds / duration.inMilliseconds;
  }

  double endFraction(Duration duration) {
    if (duration.inMilliseconds == 0) return 0.0;
    return end.inMilliseconds / duration.inMilliseconds;
  }
}

class VideoProgressBar extends StatefulWidget {
  const VideoProgressBar({
    required this.duration,
    required this.position,
    required this.buffered,
    required this.seekTo,
    required this.barHeight,
    required this.handleHeight,
    required this.drawShadow,
    required this.backgroundColor,
    required this.playedColor,
    required this.bufferedColor,
    required this.handleColor,
    super.key,
    this.onDragEnd,
    this.onDragStart,
    this.onDragUpdate,
    this.indeterminate = false,
  });

  final Duration duration;
  final Duration position;
  final List<DurationRange> buffered;
  final Function()? onDragStart;
  final Function()? onDragEnd;
  final Function()? onDragUpdate;
  final Function(Duration position) seekTo;

  final double barHeight;
  final double handleHeight;
  final bool drawShadow;
  final Color backgroundColor;
  final Color playedColor;
  final Color bufferedColor;
  final Color handleColor;

  final bool indeterminate;

  @override
  State<VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  final isDragging = ValueNotifier(false);
  final isHovering = ValueNotifier(false);
  final isIndeterminate = ValueNotifier(false);

  void _seekToRelativePosition(Offset globalPosition) {
    final renderObject = context.findRenderObject();
    if (renderObject == null) return;

    final box = renderObject as RenderBox?;
    if (box == null) return;

    final tapPos = box.globalToLocal(globalPosition);
    final relative = tapPos.dx / box.size.width;
    final position = widget.duration * relative;

    widget.seekTo(position);
  }

  @override
  void didUpdateWidget(VideoProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.indeterminate != widget.indeterminate) {
      isIndeterminate.value = widget.indeterminate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => isHovering.value = true,
      onExit: (_) => isHovering.value = false,
      child: GestureDetector(
        onHorizontalDragStart: (_) {
          widget.onDragStart?.call();
          isDragging.value = true;
        },
        onHorizontalDragUpdate: (details) {
          _seekToRelativePosition(details.globalPosition);
          widget.onDragUpdate?.call();
        },
        onHorizontalDragEnd: (_) {
          widget.onDragEnd?.call();
          isDragging.value = false;
        },
        onTapDown: (details) {
          _seekToRelativePosition(details.globalPosition);
        },
        child: _buildBar(),
      ),
    );
  }

  Widget _buildBar() {
    final isDesktop = isDesktopPlatform();

    return ValueListenableBuilder(
      valueListenable: isHovering,
      builder: (_, hovering, _) => ValueListenableBuilder(
        valueListenable: isDragging,
        builder: (_, dragging, _) {
          final barHeight = isDesktop
              ? hovering
                    ? widget.barHeight * 1.5
                    : widget.barHeight
              : dragging
              ? widget.barHeight * 1.2
              : widget.barHeight;

          return RepaintBoundary(
            child: ValueListenableBuilder(
              valueListenable: isIndeterminate,
              builder: (_, indeterminate, _) => indeterminate
                  ? Center(
                      child: SizedBox(
                        height: barHeight,
                        child: LinearProgressIndicator(
                          backgroundColor: widget.backgroundColor,
                        ),
                      ),
                    )
                  : CustomPaint(
                      painter: _ProgressBarPainter(
                        barRadius: Radius.zero,
                        position: widget.position,
                        duration: widget.duration,
                        buffered: widget.buffered,
                        barHeight: barHeight,
                        handleHeight: isDesktop
                            ? !hovering
                                  ? 0
                                  : dragging
                                  ? widget.handleHeight * 1.2
                                  : widget.handleHeight
                            : !dragging
                            ? widget.handleHeight
                            : widget.handleHeight * 1.5,
                        drawShadow: widget.drawShadow,
                        backgroundColor: widget.backgroundColor,
                        playedColor: widget.playedColor,
                        bufferedColor: widget.bufferedColor,
                        handleColor: widget.handleColor,
                        useHandle: true,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  _ProgressBarPainter({
    required this.position,
    required this.duration,
    required this.buffered,
    required this.barHeight,
    required this.handleHeight,
    required this.drawShadow,
    required this.backgroundColor,
    required this.playedColor,
    required this.bufferedColor,
    required this.handleColor,
    required this.useHandle,
    this.barRadius = const Radius.circular(4),
  });

  final Duration position;
  final Duration duration;
  final List<DurationRange> buffered;
  final double barHeight;
  final double handleHeight;
  final bool drawShadow;
  final Color backgroundColor;
  final Color playedColor;
  final Color bufferedColor;
  final Color handleColor;
  final bool useHandle;
  final Radius barRadius;

  @override
  bool shouldRepaint(_ProgressBarPainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.duration != duration ||
        oldDelegate.buffered != buffered ||
        oldDelegate.barHeight != barHeight ||
        oldDelegate.handleHeight != handleHeight ||
        oldDelegate.drawShadow != drawShadow ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.playedColor != playedColor ||
        oldDelegate.bufferedColor != bufferedColor ||
        oldDelegate.handleColor != handleColor ||
        oldDelegate.useHandle != useHandle;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final baseOffset = size.height / 2 - barHeight / 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0, baseOffset),
          Offset(size.width, baseOffset + barHeight),
        ),
        barRadius,
      ),
      Paint()..color = backgroundColor,
    );
    if (duration.inMilliseconds == 0) {
      return;
    }
    final playedPartPercent = position.inMilliseconds / duration.inMilliseconds;
    final playedPart = playedPartPercent > 1
        ? size.width
        : playedPartPercent * size.width;
    for (final range in buffered) {
      final start = range.startFraction(duration) * size.width;
      final end = range.endFraction(duration) * size.width;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(
            Offset(start, baseOffset),
            Offset(end, baseOffset + barHeight),
          ),
          barRadius,
        ),
        Paint()..color = bufferedColor,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0, baseOffset),
          Offset(playedPart, baseOffset + barHeight),
        ),
        barRadius,
      ),
      Paint()..color = playedColor,
    );
    if (useHandle) {
      if (drawShadow) {
        final shadowPath = Path()
          ..addOval(
            Rect.fromCircle(
              center: Offset(playedPart, baseOffset + barHeight / 2),
              radius: handleHeight,
            ),
          );

        canvas.drawShadow(shadowPath, Colors.black, 0.2, false);
      }

      canvas.drawCircle(
        Offset(playedPart, baseOffset + barHeight / 2),
        handleHeight,
        Paint()..color = handleColor,
      );
    }
  }
}
