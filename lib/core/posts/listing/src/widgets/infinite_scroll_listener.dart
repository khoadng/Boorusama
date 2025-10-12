// Flutter imports:
import 'package:flutter/material.dart';

class InfiniteScrollListener extends StatefulWidget {
  const InfiniteScrollListener({
    required this.scrollController,
    required this.onBottomReached,
    super.key,
    this.threshold = 0.95,
    this.child,
  });

  final ScrollController scrollController;
  final VoidCallback? onBottomReached;
  final double threshold;
  final Widget? child;

  @override
  State<InfiniteScrollListener> createState() => _InfiniteScrollListenerState();
}

class _InfiniteScrollListenerState extends State<InfiniteScrollListener> {
  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  @override
  void didUpdateWidget(InfiniteScrollListener oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController.removeListener(_onScroll);
      widget.scrollController.addListener(_onScroll);
    }
  }

  void _onScroll() {
    final callback = widget.onBottomReached;
    if (callback == null) return;

    if (!widget.scrollController.hasClients) return;

    final position = widget.scrollController.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = widget.scrollController.offset;
    final thresholdPosition = maxScroll * widget.threshold;

    if (currentScroll >= thresholdPosition) {
      callback();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox.shrink();
  }
}
