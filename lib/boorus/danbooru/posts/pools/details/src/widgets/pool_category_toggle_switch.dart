// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../../core/widgets/widgets.dart';
import '../../../pool/pool.dart';

class PoolCategoryToggleSwitch extends StatelessWidget {
  const PoolCategoryToggleSwitch({
    required this.onToggle,
    super.key,
  });

  final void Function(String order) onToggle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BooruSegmentedButton(
        initialValue: 'order',
        fixedWidth: 120,
        segments: {
          'order': context.t.explore.ordered,
          PoolDetailsOrder.latest.name: context.t.explore.latest,
          PoolDetailsOrder.oldest.name: context.t.explore.oldest,
        },
        onChanged: (value) => onToggle(value),
      ),
    );
  }
}
