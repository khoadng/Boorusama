// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import '../../../../settings/providers.dart';
import '../../../../themes/theme/types.dart';
import '../types/image_list_type.dart';
import 'expand_collapse_widgets.dart';

class OverflowClampedItem extends ConsumerWidget {
  const OverflowClampedItem({
    required this.index,
    required this.scrollController,
    required this.childBuilder,
    super.key,
  });

  final int index;
  final AutoScrollController scrollController;

  /// Builder that receives whether the item is clamped, so callers can
  /// pass `autoScrollOptions: null` when clamped (the outer widget handles it).
  final Widget Function(bool isClamped) childBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = ref.watch(
      imageListingSettingsProvider.select(
        (v) => v.itemOverflowMode.isActive,
      ),
    );
    final imageListType = ref.watch(
      imageListingSettingsProvider.select((v) => v.imageListType),
    );

    final isClamped = isActive && imageListType == ImageListType.masonry;

    if (!isClamped) {
      return childBuilder(false);
    }

    final screenHeight = MediaQuery.sizeOf(context).height;

    return AutoScrollTag(
      key: ValueKey(index),
      controller: scrollController,
      index: index,
      child: _ClampedContent(
        maxHeight: screenHeight * 0.6,
        child: childBuilder(true),
      ),
    );
  }
}

class _ClampedContent extends StatefulWidget {
  const _ClampedContent({
    required this.maxHeight,
    required this.child,
  });

  final double maxHeight;
  final Widget child;

  @override
  State<_ClampedContent> createState() => _ClampedContentState();
}

class _ClampedContentState extends State<_ClampedContent> {
  var _expanded = false;
  var _canExpand = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_expanded) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.child,
          CollapseButton(
            color: colorScheme.hintColor,
            onTap: () => collapseAndScrollBack(
              context,
              () => setState(() => _expanded = false),
            ),
          ),
        ],
      );
    }

    return Container(
      constraints: BoxConstraints(maxHeight: widget.maxHeight),
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(),
      child: Stack(
        children: [
          NotificationListener<ScrollMetricsNotification>(
            onNotification: (notification) {
              final overflow = notification.metrics.maxScrollExtent > 0;
              if (overflow != _canExpand) {
                setState(() => _canExpand = overflow);
              }
              return false;
            },
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: widget.child,
            ),
          ),
          if (_canExpand)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ExpandOverlay(
                color: colorScheme.surfaceContainerLow,
                hintColor: colorScheme.hintColor,
                height: widget.maxHeight * 0.25,
                onTap: () => setState(() => _expanded = true),
              ),
            ),
        ],
      ),
    );
  }
}
