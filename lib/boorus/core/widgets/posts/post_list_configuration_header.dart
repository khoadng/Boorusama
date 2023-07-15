// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/dart.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/theme/theme.dart';

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
    this.trailing,
    this.toolBarLeadingBuilder,
    this.hasBlacklist = false,
  });

  final List<HiddenData> tags;
  final void Function(String tag, bool value) onChanged;
  final VoidCallback onClosed;
  final Widget? trailing;
  final VoidCallback onDisableAll;
  final VoidCallback onEnableAll;
  final int hiddenCount;
  final Widget Function(BuildContext contex)? toolBarLeadingBuilder;
  final bool hasBlacklist;

  @override
  State<PostListConfigurationHeader> createState() =>
      _PostListConfigurationHeaderState();
}

class _PostListConfigurationHeaderState
    extends State<PostListConfigurationHeader> {
  var expanded = false;

  @override
  Widget build(BuildContext context) {
    final allTagsHidden = widget.tags.every((e) => !e.active);

    return Card(
      color: expanded ? null : Colors.transparent,
      elevation: expanded ? null : 0,
      shadowColor: expanded ? null : Colors.transparent,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          listTileTheme: ListTileTheme.of(context).copyWith(
            contentPadding: EdgeInsets.only(left: widget.hasBlacklist ? 6 : 0),
            horizontalTitleGap: 0,
            visualDensity: const ShrinkVisualDensity(),
          ),
        ),
        child: widget.hasBlacklist
            ? ExpansionTile(
                controlAffinity: ListTileControlAffinity.leading,
                trailing: expanded
                    ? IconButton(
                        onPressed: widget.onClosed,
                        icon: const Icon(Icons.close),
                      )
                    : null,
                onExpansionChanged: (value) => {
                  setState(() {
                    expanded = value;
                  })
                },
                title: Row(
                  children: [
                    const Text('Blacklisted'),
                    const SizedBox(width: 4),
                    if (widget.hiddenCount > 0)
                      Chip(
                          padding: EdgeInsets.zero,
                          visualDensity: const ShrinkVisualDensity(),
                          backgroundColor: context.colorScheme.primary,
                          label: Text(
                            widget.hiddenCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
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
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        for (var tag in widget.tags)
                          _BadgedChip(
                            label: tag.name.replaceUnderscoreWithSpace(),
                            count: tag.count,
                            active: tag.active,
                            onChanged: (value) =>
                                widget.onChanged(tag.name, value),
                          ),
                        ActionChip(
                          visualDensity: const ShrinkVisualDensity(),
                          shape: StadiumBorder(
                            side: BorderSide(
                              width: 1,
                              color: context.theme.hintColor,
                            ),
                          ),
                          label: allTagsHidden
                              ? const Text('Re-enable all')
                              : const Text('Disable all'),
                          onPressed: allTagsHidden
                              ? widget.onEnableAll
                              : widget.onDisableAll,
                        ),
                      ],
                    ),
                  )
                ],
              )
            : ListTile(
                title: Row(
                  children: [
                    widget.toolBarLeadingBuilder?.call(context) ??
                        const SizedBox.shrink(),
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
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: ChoiceChip(
          visualDensity: const ShrinkVisualDensity(),
          selected: active,
          backgroundColor: context.theme.scaffoldBackgroundColor,
          label: Text(label),
          onSelected: (value) => onChanged(value),
        ));
  }
}
