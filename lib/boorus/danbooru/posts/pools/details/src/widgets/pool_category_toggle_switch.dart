// Flutter imports:
import 'package:flutter/material.dart';

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
          'order': 'Ordered',
          PoolDetailsOrder.latest.name: 'Latest',
          PoolDetailsOrder.oldest.name: 'Oldest',
        },
        onChanged: (value) => onToggle(value),
      ),
    );
  }
}
