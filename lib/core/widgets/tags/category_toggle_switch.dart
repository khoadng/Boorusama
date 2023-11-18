// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/feats/tags/tag_filter_category.dart';
import 'package:boorusama/foundation/i18n.dart';

class CategoryToggleSwitch extends StatefulWidget {
  const CategoryToggleSwitch({
    super.key,
    required this.onToggle,
  });

  final void Function(TagFilterCategory category) onToggle;

  @override
  State<CategoryToggleSwitch> createState() => _CategoryToggleSwitchState();
}

class _CategoryToggleSwitchState extends State<CategoryToggleSwitch> {
  var selected = TagFilterCategory.newest;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SegmentedButton(
        showSelectedIcon: false,
        segments: TagFilterCategory.values
            .map((e) => ButtonSegment(
                value: e,
                label: Text(switch (e) {
                  TagFilterCategory.newest => 'tag.explore.new'.tr(),
                  TagFilterCategory.popular => 'tag.explore.popular'.tr(),
                })))
            .toList(),
        selected: {selected},
        onSelectionChanged: (value) {
          setState(() {
            selected = value.first;
            widget.onToggle(value.first);
          });
        },
      ),
    );
  }
}
