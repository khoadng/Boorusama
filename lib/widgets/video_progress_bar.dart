// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:video_player/video_player.dart';

// Project imports:
import 'package:boorusama/foundation/platform.dart';

class VideoProgressBar extends StatefulWidget {
  const VideoProgressBar({
    super.key,
    required this.duration,
    required this.position,
    required this.buffered,
    this.onDragEnd,
    this.onDragStart,
    this.onDragUpdate,
    required this.seekTo,
    required this.barHeight,
    required this.handleHeight,
    required this.drawShadow,
    required this.backgroundColor,
    required this.playedColor,
    required this.bufferedColor,
    required this.handleColor,
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

  @override
  State<VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar>
    with SingleTickerProviderStateMixin {
  final isDragging = ValueNotifier(false);
  final isHovering = ValueNotifier(false);
  late AnimationController _animationController;
  late Animation<double> _animation;
  Duration _lastPosition = Duration.zero;
  Duration? _dragPosition;
  bool _recentlyDragged = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _lastPosition = widget.position;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(VideoProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Skip animation if video is looping or recently dragged
    final isLooping = _lastPosition.inMilliseconds >
            widget.duration.inMilliseconds * 0.95 &&
        widget.position.inMilliseconds < widget.duration.inMilliseconds * 0.05;

    if (widget.position != _lastPosition &&
        !isDragging.value &&
        !_recentlyDragged) {
      if (isLooping) {
        _updatePositionWithoutAnimation();
      } else {
        _updatePositionWithAnimation();
      }
    }
  }

  void _updatePositionWithoutAnimation() {
    _lastPosition = widget.position;
    _animation = Tween<double>(
      begin: widget.position.inMilliseconds.toDouble(),
      end: widget.position.inMilliseconds.toDouble(),
    ).animate(_animationController);
    _animationController.value = 1.0;
  }

  void _updatePositionWithAnimation() {
    _animation = Tween<double>(
      begin: _lastPosition.inMilliseconds.toDouble(),
      end: widget.position.inMilliseconds.toDouble(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    _animationController
      ..duration = const Duration(milliseconds: 500)
      ..forward(from: 0);

    _lastPosition = widget.position;
  }

  void _onDragStart() {
    widget.onDragStart?.call();
    isDragging.value = true;
    _animationController.stop();
    _recentlyDragged = true;
  }

  void _onDragEnd() {
    widget.onDragEnd?.call();
    isDragging.value = false;
    _lastPosition = _dragPosition ?? widget.position;
    _dragPosition = null;

    // Reset recently dragged flag after a brief delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _recentlyDragged = false;
      }
    });
  }

  void _seekToRelativePosition(Offset globalPosition) {
    final renderObject = context.findRenderObject();
    if (renderObject == null) return;

    final box = renderObject as RenderBox?;
    if (box == null) return;

    final tapPos = box.globalToLocal(globalPosition);
    final relative = tapPos.dx / box.size.width;
    final position = widget.duration * relative;

    _dragPosition = position;
    widget.seekTo(position);
    // Update last position when seeking
    _lastPosition = position;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => isHovering.value = true,
      onExit: (_) => isHovering.value = false,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return GestureDetector(
            onHorizontalDragStart: (_) => _onDragStart(),
            onHorizontalDragUpdate: (details) {
              _seekToRelativePosition(details.globalPosition);
              widget.onDragUpdate?.call();
            },
            onHorizontalDragEnd: (_) => _onDragEnd(),
            onTapDown: (details) {
              _seekToRelativePosition(details.globalPosition);
            },
            child: _buildBar(),
          );
        },
      ),
    );
  }

  Widget _buildBar() {
    final isDesktop = isDesktopPlatform();

    return Center(
      child: Container(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        color: Colors.transparent,
        child: ValueListenableBuilder(
          valueListenable: isDragging,
          builder: (_, dragging, __) => ValueListenableBuilder(
            valueListenable: isHovering,
            builder: (_, hovering, __) {
              final position = _dragPosition ??
                  (dragging || _recentlyDragged
                      ? widget.position
                      : Duration(milliseconds: _animation.value.toInt()));

              return CustomPaint(
                painter: _ProgressBarPainter(
                  position: position,
                  duration: widget.duration,
                  buffered: widget.buffered,
                  barHeight: isDesktop
                      ? hovering
                          ? widget.barHeight * 2
                          : widget.barHeight
                      : dragging
                          ? widget.barHeight * 1.5
                          : widget.barHeight,
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
              );
            },
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
