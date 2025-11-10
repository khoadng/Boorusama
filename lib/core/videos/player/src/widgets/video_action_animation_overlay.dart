// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../settings/providers.dart';

class VideoActionAnimationOverlay<T> extends ConsumerStatefulWidget {
  const VideoActionAnimationOverlay({
    required this.triggerNotifier,
    required this.iconBuilder,
    required this.duration,
    this.showEnd = 0.15,
    this.hideStart = 0.7,
    super.key,
  });

  final ValueNotifier<T?> triggerNotifier;
  final Widget Function(T value, double progress) iconBuilder;
  final Duration duration;
  final double showEnd;
  final double hideStart;

  @override
  ConsumerState<VideoActionAnimationOverlay<T>> createState() =>
      _VideoActionAnimationOverlayState<T>();
}

class _VideoActionAnimationOverlayState<T>
    extends ConsumerState<VideoActionAnimationOverlay<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    widget.triggerNotifier.addListener(_onTriggerChanged);
  }

  @override
  void dispose() {
    widget.triggerNotifier.removeListener(_onTriggerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTriggerChanged() {
    final value = widget.triggerNotifier.value;
    final reduceAnimations = ref.read(
      settingsProvider.select((value) => value.reduceAnimations),
    );

    if (value != null && !reduceAnimations) {
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T?>(
      valueListenable: widget.triggerNotifier,
      builder: (context, value, child) {
        if (value == null) return const SizedBox.shrink();

        return Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final progress = _calculateShowPauseHideValue(
                  _controller.value,
                  showEnd: widget.showEnd,
                  hideStart: widget.hideStart,
                );
                return widget.iconBuilder(value, progress);
              },
            ),
          ),
        );
      },
    );
  }
}

double _calculateShowPauseHideValue(
  double t, {
  double showEnd = 0.15,
  double hideStart = 0.7,
}) => switch ((t, showEnd, hideStart)) {
  (_, <= 0, _) => 0, // showEnd invalid
  (_, _, >= 1) => 1, // hideStart invalid
  (final t, final end, _) when t < end => Curves.easeOut.transform(t / end),
  (final t, _, final start) when t < start => 1,
  (final t, _, final start) =>
    1 - Curves.easeIn.transform((t - start) / (1 - start)),
};
