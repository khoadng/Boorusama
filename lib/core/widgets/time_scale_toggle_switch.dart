// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/feats/types.dart';
import 'package:boorusama/foundation/i18n.dart';

class TimeScaleToggleSwitch extends StatefulWidget {
  const TimeScaleToggleSwitch({
    super.key,
    required this.onToggle,
  });

  final void Function(TimeScale category) onToggle;

  @override
  State<TimeScaleToggleSwitch> createState() => _TimeScaleToggleSwitchState();
}

class _TimeScaleToggleSwitchState extends State<TimeScaleToggleSwitch> {
  var selected = TimeScale.day;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SegmentedButton(
        showSelectedIcon: false,
        segments: TimeScale.values
            .map((e) => ButtonSegment(
                  value: e,
                  label: Text(_timeScaleToString(e).tr()),
                ))
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

String _timeScaleToString(TimeScale scale) {
  switch (scale) {
    case TimeScale.month:
      return 'dateRange.month';
    case TimeScale.week:
      return 'dateRange.week';
    case TimeScale.day:
      return 'dateRange.day';
  }
}
