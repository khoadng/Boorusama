// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/widgets/widgets.dart';

class PeriodToggleSwitch extends StatelessWidget {
  const PeriodToggleSwitch({
    super.key,
    required this.onToggle,
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
