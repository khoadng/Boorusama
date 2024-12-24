// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/widgets/widgets.dart';
import '../../feats/posts/posts.dart';

class PeriodToggleSwitch extends StatelessWidget {
  const PeriodToggleSwitch({
    required this.onToggle,
    super.key,
  });

  final void Function(MoebooruTimePeriod period) onToggle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BooruSegmentedButton(
        segments: {
          for (final entry in MoebooruTimePeriod.values) entry: entry.name,
        },
        initialValue: MoebooruTimePeriod.day,
        onChanged: (value) => onToggle(value),
      ),
    );
  }
}
