// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/dart.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/string.dart';

typedef HiddenData = ({
  String name,
  int count,
  bool active,
});

class PostListConfigurationHeader extends StatefulWidget {
  const PostListConfigurationHeader({
    super.key,
    required this.tags,
    required this.onChanged,
    required this.hiddenCount,
    required this.onClosed,
    required this.onDisableAll,
    required this.onEnableAll,
    required this.postCount,
    this.trailing,
    this.hasBlacklist = false,
    this.initiallyExpanded = false,
    this.axis = Axis.horizontal,
    this.onExpansionChanged,
  });

  final List<HiddenData>? tags;
  final void Function(String tag, bool value) onChanged;
  final VoidCallback onClosed;
  final Widget? trailing;
  final VoidCallback onDisableAll;
  final VoidCallback onEnableAll;
  final int? hiddenCount;
  final bool hasBlacklist;
  final bool initiallyExpanded;
  final Axis axis;
  final int postCount;
  final void Function(bool value)? onExpansionChanged;

  @override
  State<PostListConfigurationHeader> createState() =>
      _PostListConfigurationHeaderState();
}

class _PostListConfigurationHeaderState
    extends State<PostListConfigurationHeader> {
  late var hiddenTags = widget.tags;
  late var expanded = widget.initiallyExpanded;

  bool? get allTagsHidden => hiddenTags?.every((e) => !e.active);

  @override
  void didUpdateWidget(covariant PostListConfigurationHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tags != oldWidget.tags) {
      setState(() {
        hiddenTags = widget.tags;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var tags = hiddenTags != null
        ? [
            for (var tag in hiddenTags!)
              _BadgedChip(
                label: tag.name.replaceUnderscoreWithSpace(),
                count: tag.count,
                active: tag.active,
                onChanged: (value) => widget.onChanged(tag.name, value),
              ),
            if (allTagsHidden != null)
              ActionChip(
                visualDensity: const ShrinkVisualDensity(),
                side: BorderSide(
                  width: 1,
                  color: context.theme.hintColor,
                ),
                shape: StadiumBorder(
                  side: BorderSide(
                    width: 1,
                    color: context.theme.hintColor,
                  ),
                ),
                label: allTagsHidden!
                    ? const Text('blacklisted_tags.reenable_all').tr()
                    : const Text('blacklisted_tags.disable_all').tr(),
                onPressed:
                    allTagsHidden! ? widget.onEnableAll : widget.onDisableAll,
              ),
          ]
        : null;

    return Card(
      color: widget.axis == Axis.horizontal && expanded
          ? null
          : Colors.transparent,
      elevation: widget.axis == Axis.horizontal && expanded ? null : 0,
      shadowColor: widget.axis == Axis.horizontal && expanded
          ? null
          : Colors.transparent,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          listTileTheme: ListTileTheme.of(context).copyWith(
            contentPadding: EdgeInsets.only(left: widget.hasBlacklist ? 6 : 0),
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
                    !expanded
                        ? const Icon(Symbols.keyboard_arrow_right)
                        : const Icon(Symbols.keyboard_arrow_down),
                    const Spacer()
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
                  })
                },
                title: Row(
                  children: [
                    const SizedBox(width: 8),
                    const Text('blacklisted_tags.blacklisted_header_title')
                        .tr(),
                    const SizedBox(width: 8),
                    if (widget.hiddenCount != null)
                      if (widget.hiddenCount! > 0)
                        Chip(
                          padding: EdgeInsets.zero,
                          visualDensity: const ShrinkVisualDensity(),
                          backgroundColor: context.colorScheme.primary,
                          label: Text(
                            '${widget.hiddenCount} of ${widget.postCount}',
                            style: TextStyle(
                              color: context.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    const Spacer(),
                    expanded
                        ? const SizedBox.shrink()
                        : FittedBox(
                            child: widget.trailing,
                          ),
                  ],
                ),
                expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (tags != null)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: kPreferredLayout.isMobile ? 8 : 0,
                      ),
                      child: widget.axis == Axis.horizontal
                          ? Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: tags,
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (var tag in tags)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: tag,
                                  ),
                              ],
                            ),
                    )
                  else
                    const SizedBox(
                      height: 36,
                      width: 36,
                    ),
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
                        style: context.textTheme.titleLarge,
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

class _BadgedChip extends StatelessWidget {
  const _BadgedChip({
    required this.label,
    required this.count,
    required this.active,
    required this.onChanged,
  });

  final int count;
  final bool active;
  final String label;
  final void Function(bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Badge(
      offset: switch (count.digitCount()) {
        < 2 => const Offset(0, -4),
        2 => const Offset(-4, -4),
        3 => const Offset(-8, -4),
        _ => const Offset(-12, -4),
      },
      backgroundColor: context.colorScheme.primary,
      label: Text(
        count.toString(),
        style: TextStyle(
          color: context.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: ChoiceChip(
        showCheckmark: false,
        visualDensity: const ShrinkVisualDensity(),
        selected: active,
        side: BorderSide(
          width: 1,
          color: active ? context.theme.hintColor : Colors.transparent,
        ),
        backgroundColor: context.colorScheme.surface,
        label: Text(label),
        onSelected: (value) => onChanged(value),
      ),
    );
  }
}
