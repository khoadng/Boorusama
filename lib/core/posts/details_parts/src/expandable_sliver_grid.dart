// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sliver_tools/sliver_tools.dart';

class ExpandableSliverGrid extends StatefulWidget {
  const ExpandableSliverGrid({
    required this.itemCount,
    required this.gridDelegate,
    required this.builder,
    required this.shouldLimit,
    this.buttonBuilder,
    this.onShowAll,
    super.key,
  });

  final int itemCount;
  final SliverGridDelegate gridDelegate;
  final Widget Function(BuildContext context, int index) builder;
  final int? Function(int totalCount, int expandCount) shouldLimit;
  final Widget Function(
    BuildContext context,
    int hiddenCount,
    int expandCount,
    VoidCallback onExpand,
  )?
  buttonBuilder;
  final VoidCallback? onShowAll;

  @override
  State<ExpandableSliverGrid> createState() => _ExpandableSliverGridState();
}

class _ExpandableSliverGridState extends State<ExpandableSliverGrid> {
  var _expandCount = 0;

  @override
  Widget build(BuildContext context) {
    final limit = widget.shouldLimit(widget.itemCount, _expandCount);

    if (limit == null) {
      final canCollapse = _expandCount > 0;
      final showNavButton = canCollapse && widget.onShowAll != null;

      return MultiSliver(
        children: [
          SliverGrid.builder(
            itemCount: widget.itemCount,
            gridDelegate: widget.gridDelegate,
            itemBuilder: widget.builder,
          ),
          if (canCollapse)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Expanded(
                      child:
                          widget.buttonBuilder?.call(
                            context,
                            0,
                            _expandCount,
                            () => setState(() => _expandCount = 0),
                          ) ??
                          _ExpandCollapseButton(
                            icon: Symbols.expand_less,
                            text: context.t.post.detail.show_less,
                            onTap: () => setState(() => _expandCount = 0),
                          ),
                    ),
                    if (showNavButton) ...[
                      const SizedBox(width: 8),
                      const SizedBox(
                        height: 24,
                        child: VerticalDivider(),
                      ),
                      IconButton(
                        onPressed: widget.onShowAll,
                        icon: const Icon(Symbols.arrow_forward_ios),
                        tooltip: context.t.generic.action.view_all,
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      );
    }

    final displayCount = limit.clamp(0, widget.itemCount);
    final hasMore = displayCount < widget.itemCount;

    // Calculate next step's display count to show how many items will be revealed
    final nextLimit = widget.shouldLimit(widget.itemCount, _expandCount + 1);
    final nextDisplayCount =
        nextLimit?.clamp(0, widget.itemCount) ?? widget.itemCount;
    final nextStepItemCount = nextDisplayCount - displayCount;

    // Show navigation button after first expand when there's more content
    final showNavButton =
        _expandCount > 0 && hasMore && widget.onShowAll != null;

    return MultiSliver(
      children: [
        SliverGrid.builder(
          itemCount: displayCount,
          gridDelegate: widget.gridDelegate,
          itemBuilder: widget.builder,
        ),
        if (hasMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Expanded(
                    child:
                        widget.buttonBuilder?.call(
                          context,
                          nextStepItemCount,
                          _expandCount,
                          () => setState(() => _expandCount++),
                        ) ??
                        _ExpandCollapseButton(
                          icon: Symbols.expand_more,
                          text: context.t.post.detail.show_n_more(
                            n: nextStepItemCount,
                          ),
                          onTap: () => setState(() => _expandCount++),
                        ),
                  ),
                  if (showNavButton) ...[
                    const SizedBox(width: 8),
                    const SizedBox(
                      height: 24,
                      child: VerticalDivider(),
                    ),
                    IconButton(
                      onPressed: widget.onShowAll,
                      icon: const Icon(Symbols.arrow_forward_ios),
                      tooltip: context.t.generic.action.view_all,
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ExpandCollapseButton extends StatelessWidget {
  const _ExpandCollapseButton({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon),
              const SizedBox(width: 4),
              Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
