// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:video_player/video_player.dart';

class VideoProgressBar extends StatefulWidget {
  const VideoProgressBar({
    required this.duration,
    required this.position,
    required this.buffered,
    this.onDragEnd,
    this.onDragStart,
    this.onDragUpdate,
    required this.seekTo,
    Key? key,
    required this.barHeight,
    required this.handleHeight,
    required this.drawShadow,
    required this.backgroundColor,
    required this.playedColor,
    required this.bufferedColor,
    required this.handleColor,
  }) : super(key: key);

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

  @override
  State<VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  void _seekToRelativePosition(Offset globalPosition) {
    final box = context.findRenderObject()! as RenderBox;
    final Offset tapPos = box.globalToLocal(globalPosition);
    final double relative = tapPos.dx / box.size.width;
    final Duration position = widget.duration * relative;
    widget.seekTo(position);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (DragStartDetails details) {
        widget.onDragStart?.call();
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        _seekToRelativePosition(details.globalPosition);
        widget.onDragUpdate?.call();
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        widget.onDragEnd?.call();
      },
      onTapDown: (TapDownDetails details) {
        _seekToRelativePosition(details.globalPosition);
      },
      child: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.transparent,
          child: CustomPaint(
            painter: _ProgressBarPainter(
              position: widget.position,
              duration: widget.duration,
              buffered: widget.buffered,
              barHeight: widget.barHeight,
              handleHeight: widget.handleHeight,
              drawShadow: widget.drawShadow,
              backgroundColor: widget.backgroundColor,
              playedColor: widget.playedColor,
              bufferedColor: widget.bufferedColor,
              handleColor: widget.handleColor,
              useHandle: true,
            ),
          ),
        ),
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

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final baseOffset = size.height / 2 - barHeight / 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, baseOffset),
          Offset(size.width, baseOffset + barHeight),
        ),
        const Radius.circular(4.0),
      ),
      Paint()..color = backgroundColor,
    );
    if (duration.inMilliseconds == 0) {
      return;
    }
    final double playedPartPercent =
        position.inMilliseconds / duration.inMilliseconds;
    final double playedPart =
        playedPartPercent > 1 ? size.width : playedPartPercent * size.width;
    for (final DurationRange range in buffered) {
      final double start = range.startFraction(duration) * size.width;
      final double end = range.endFraction(duration) * size.width;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(
            Offset(start, baseOffset),
            Offset(end, baseOffset + barHeight),
          ),
          const Radius.circular(4.0),
        ),
        Paint()..color = bufferedColor,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, baseOffset),
          Offset(playedPart, baseOffset + barHeight),
        ),
        const Radius.circular(4.0),
      ),
      Paint()..color = playedColor,
    );
    if (useHandle) {
      if (drawShadow) {
        final Path shadowPath = Path()
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
