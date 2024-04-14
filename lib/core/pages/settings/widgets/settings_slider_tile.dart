// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/foundation/i18n.dart';

class SettingsSliderTile extends StatelessWidget {
  const SettingsSliderTile({
    super.key,
    required this.title,
    required this.value,
    required this.divisions,
    this.min = 0.0,
    required this.max,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final String title;
  final double value;
  final int divisions;
  final double min;
  final double max;
  final void Function(double) onChanged;
  final void Function(double) onChangeEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: 16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              title,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 16,
              ),
            ).tr(),
          ),
          Expanded(
            child: Slider(
              label: value.toStringAsFixed(1),
              divisions: divisions,
              max: max,
              min: min,
              value: value,
              onChangeEnd: onChangeEnd,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
