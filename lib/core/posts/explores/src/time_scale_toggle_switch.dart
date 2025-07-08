// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../widgets/widgets.dart';
import 'types.dart';

class TimeScaleToggleSwitch extends StatelessWidget {
  const TimeScaleToggleSwitch({
    required this.onToggle,
    super.key,
  });

  final void Function(TimeScale category) onToggle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BooruSegmentedButton(
        segments: {
          for (final entry in TimeScale.values)
            entry: _timeScaleToString(context, entry),
        },
        initialValue: TimeScale.day,
        onChanged: (value) => onToggle(value),
      ),
    );
  }
}

String _timeScaleToString(BuildContext context, TimeScale scale) =>
    switch (scale) {
      TimeScale.month => context.t.dateRange.month,
      TimeScale.week => context.t.dateRange.week,
      TimeScale.day => context.t.dateRange.day,
    };
