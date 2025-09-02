// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../foundation/utils/flutter_utils.dart';

class PostListConfigurationHeader extends StatefulWidget {
  const PostListConfigurationHeader({
    required this.hiddenCount,
    required this.postCount,
    required this.blacklistControls,
    super.key,
    this.trailing,
    this.hasBlacklist = false,
    this.initiallyExpanded = false,
    this.axis = Axis.horizontal,
    this.onExpansionChanged,
  });

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
    final colorScheme = Theme.of(context).colorScheme;
    final hiddenCount = widget.hiddenCount;

    return Card(
      color: widget.axis == Axis.horizontal && expanded
          ? colorScheme.surface
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        child: widget.hasBlacklist
            ? ExpansionTile(
                initiallyExpanded: expanded,
                leading: !expanded
                    ? const Icon(Symbols.keyboard_arrow_right)
                    : const Icon(Symbols.keyboard_arrow_down),
                controlAffinity: ListTileControlAffinity.leading,
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
                        Text(
                          context.t.blacklisted_tags.blacklisted_header_title,
                        ),
                        if (constraints.maxWidth > 250)
                          const SizedBox(width: 8),
                        if (hiddenCount != null)
                          if (hiddenCount > 0)
                            if (constraints.maxWidth > 250)
                              Chip(
                                padding: EdgeInsets.zero,
                                visualDensity: const ShrinkVisualDensity(),
                                backgroundColor: colorScheme.primary,
                                label: Text(
                                  context.t.posts.hidden_count(
                                    hidden: hiddenCount,
                                    total: widget.postCount,
                                  ),
                                  style: TextStyle(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                        const Spacer(),
                        FittedBox(
                          child: widget.trailing,
                        ),
                        const SizedBox(width: 4),
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
                        context.t.posts.counter(n: widget.postCount),
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
    );
  }
}
