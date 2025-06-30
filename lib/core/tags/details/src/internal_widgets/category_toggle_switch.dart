// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../core/widgets/widgets.dart';
import '../../../tag/tag.dart';

class CategoryToggleSwitch extends StatelessWidget {
  const CategoryToggleSwitch({
    required this.onToggle,
    super.key,
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
