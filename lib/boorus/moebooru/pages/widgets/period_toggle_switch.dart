// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:toggle_switch/toggle_switch.dart';

// Project imports:
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class PeriodToggleSwitch extends StatefulWidget {
  const PeriodToggleSwitch({
    super.key,
    required this.onToggle,
  });

  final void Function(MoebooruTimePeriod period) onToggle;

  @override
  State<PeriodToggleSwitch> createState() => _PeriodToggleSwitchState();
}

class _PeriodToggleSwitchState extends State<PeriodToggleSwitch> {
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
            MoebooruTimePeriod.day.name,
            MoebooruTimePeriod.week.name,
            MoebooruTimePeriod.month.name,
            MoebooruTimePeriod.year.name,
          ],
          activeBgColor: [context.colorScheme.primary],
          inactiveBgColor: context.colorScheme.background,
          borderWidth: 1,
          borderColor: [context.theme.hintColor],
          onToggle: (index) {
            if (index == 0) {
              widget.onToggle(MoebooruTimePeriod.day);
            } else if (index == 1) {
              widget.onToggle(MoebooruTimePeriod.week);
            } else if (index == 2) {
              widget.onToggle(MoebooruTimePeriod.month);
            } else if (index == 3) {
              widget.onToggle(MoebooruTimePeriod.year);
            }

            selected.value = index ?? 0;
          },
        ),
      ),
    );
  }
}

// String _timeScaleToString(TimeScale scale) {
//   switch (scale) {
//     case TimeScale.month:
//       return 'dateRange.month';
//     case TimeScale.week:
//       return 'dateRange.week';
//     case TimeScale.day:
//       return 'dateRange.day';
//   }
// }
