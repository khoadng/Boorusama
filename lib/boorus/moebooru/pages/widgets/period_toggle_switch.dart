// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';

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
  var selected = MoebooruTimePeriod.day;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SegmentedButton(
        showSelectedIcon: false,
        segments: MoebooruTimePeriod.values
            .map((e) => ButtonSegment(
                  value: e,
                  label: Text(e.name),
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
