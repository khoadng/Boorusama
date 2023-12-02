// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/feats/types.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/widgets.dart';

class TimeScaleToggleSwitch extends StatelessWidget {
  const TimeScaleToggleSwitch({
    super.key,
    required this.onToggle,
  });

  final void Function(TimeScale category) onToggle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BooruSegmentedButton(
        segments: {
          for (final entry in TimeScale.values)
            entry: _timeScaleToString(entry).tr(),
        },
        initialValue: TimeScale.day,
        onChanged: (value) => onToggle(value),
      ),
    );
  }
}

String _timeScaleToString(TimeScale scale) => switch (scale) {
      TimeScale.month => 'dateRange.month',
      TimeScale.week => 'dateRange.week',
      TimeScale.day => 'dateRange.day'
    };
