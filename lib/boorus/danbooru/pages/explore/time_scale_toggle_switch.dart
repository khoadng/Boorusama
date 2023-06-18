// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:toggle_switch/toggle_switch.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/types.dart';
import 'package:boorusama/flutter.dart';
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
  final ValueNotifier<int> selected = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ValueListenableBuilder<int>(
        valueListenable: selected,
        builder: (context, value, _) => ToggleSwitch(
          dividerColor: Colors.black,
          changeOnTap: false,
          initialLabelIndex: value,
          minWidth: 100,
          minHeight: 30,
          cornerRadius: 5,
          labels: [
            _timeScaleToString(TimeScale.day).tr(),
            _timeScaleToString(TimeScale.week).tr(),
            _timeScaleToString(TimeScale.month).tr(),
          ],
          activeBgColor: [context.colorScheme.primary],
          inactiveBgColor: context.colorScheme.background,
          borderWidth: 1,
          borderColor: [context.theme.hintColor],
          onToggle: (index) {
            if (index == 0) {
              widget.onToggle(TimeScale.day);
            } else if (index == 1) {
              widget.onToggle(TimeScale.week);
            } else {
              widget.onToggle(TimeScale.month);
            }

            selected.value = index ?? 0;
          },
        ),
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
