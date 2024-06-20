// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/widgets.dart';

class CategoryToggleSwitch extends StatelessWidget {
  const CategoryToggleSwitch({
    super.key,
    required this.onToggle,
  });

  final void Function(TagFilterCategory category) onToggle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BooruSegmentedButton(
        initialValue: TagFilterCategory.newest,
        fixedWidth: 120,
        segments: {
          TagFilterCategory.newest: 'tag.explore.new'.tr(),
          TagFilterCategory.popular: 'tag.explore.popular'.tr(),
        },
        onChanged: (value) => onToggle(value),
      ),
    );
  }
}
