// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:toggle_switch/toggle_switch.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tag_filter_category.dart';
import 'package:boorusama/flutter.dart';
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
  final ValueNotifier<int> selected = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ValueListenableBuilder<int>(
        valueListenable: selected,
        builder: (context, value, _) => ToggleSwitch(
          customTextStyles: const [
            TextStyle(fontWeight: FontWeight.w700),
            TextStyle(fontWeight: FontWeight.w700),
          ],
          changeOnTap: false,
          initialLabelIndex: value,
          minWidth: 100,
          minHeight: 30,
          cornerRadius: 5,
          labels: [
            'tag.explore.new'.tr(),
            'tag.explore.popular'.tr(),
          ],
          activeBgColor: [context.colorScheme.primary],
          inactiveBgColor: context.colorScheme.background,
          borderWidth: 1,
          borderColor: [context.theme.hintColor],
          onToggle: (index) {
            index == 0
                ? widget.onToggle(TagFilterCategory.newest)
                : widget.onToggle(TagFilterCategory.popular);

            selected.value = index ?? 0;
          },
        ),
      ),
    );
  }
}
