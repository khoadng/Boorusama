// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../foundation/display/media_query_utils.dart';
import '../../../../utils/flutter_utils.dart';

typedef HiddenData = ({
  String name,
  int count,
  bool active,
});

class PostListConfigurationHeader extends StatefulWidget {
  const PostListConfigurationHeader({
    required this.hiddenCount,
    required this.onClosed,
    required this.postCount,
    required this.blacklistControls,
    super.key,
    this.trailing,
    this.hasBlacklist = false,
    this.initiallyExpanded = false,
    this.axis = Axis.horizontal,
    this.onExpansionChanged,
  });

  final VoidCallback onClosed;
  final Widget? trailing;
  final int? hiddenCount;
  final bool hasBlacklist;
  final bool initiallyExpanded;
  final Axis axis;
  final int postCount;
  final void Function(bool value)? onExpansionChanged;
  final Widget blacklistControls;

  @override
  State<PostListConfigurationHeader> createState() =>
      _PostListConfigurationHeaderState();
}

class _PostListConfigurationHeaderState
    extends State<PostListConfigurationHeader> {
  late var expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return RemoveLeftPaddingOnLargeScreen(
      child: Card(
        color: widget.axis == Axis.horizontal && expanded
            ? Theme.of(context).colorScheme.surface
            : Colors.transparent,
        elevation: widget.axis == Axis.horizontal && expanded ? null : 0,
        shadowColor: widget.axis == Axis.horizontal && expanded
            ? null
            : Colors.transparent,
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            listTileTheme: ListTileTheme.of(context).copyWith(
              contentPadding: EdgeInsets.zero,
              horizontalTitleGap: 0,
              minVerticalPadding: 0,
              visualDensity: const ShrinkVisualDensity(),
            ),
          ),
          child: widget.hasBlacklist
              ? ExpansionTile(
                  initiallyExpanded: expanded,
                  leading: Column(
                    children: [
                      const Spacer(),
                      if (!expanded)
                        const Icon(Symbols.keyboard_arrow_right)
                      else
                        const Icon(Symbols.keyboard_arrow_down),
                      const Spacer(),
                    ],
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  trailing: widget.axis == Axis.horizontal && expanded
                      ? IconButton(
                          onPressed: widget.onClosed,
                          icon: const Icon(Symbols.close),
                        )
                      : null,
                  onExpansionChanged: (value) => {
                    setState(() {
                      expanded = value;
                      widget.onExpansionChanged?.call(value);
                    }),
                  },
                  title: LayoutBuilder(
                    builder: (context, constraints) {
                      return Row(
                        children: [
                          const SizedBox(width: 8),
                          const Text(
                            'blacklisted_tags.blacklisted_header_title',
                          ).tr(),
                          if (constraints.maxWidth > 250)
                            const SizedBox(width: 8),
                          if (widget.hiddenCount != null)
                            if (widget.hiddenCount! > 0)
                              if (constraints.maxWidth > 250)
                                Chip(
                                  padding: EdgeInsets.zero,
                                  visualDensity: const ShrinkVisualDensity(),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  label: Text(
                                    '${widget.hiddenCount} of ${widget.postCount}',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                          const Spacer(),
                          if (expanded)
                            const SizedBox.shrink()
                          else
                            FittedBox(
                              child: widget.trailing,
                            ),
                        ],
                      );
                    },
                  ),
                  expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    widget.blacklistControls,
                  ],
                )
              : ListTile(
                  minVerticalPadding: 0,
                  contentPadding: EdgeInsets.zero,
                  title: Row(
                    children: [
                      if (widget.axis == Axis.horizontal)
                        Text(
                          '${widget.postCount} Posts',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      const Spacer(),
                      FittedBox(
                        child: widget.trailing,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
