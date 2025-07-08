// Flutter imports:
import 'package:flutter/material.dart';

class SettingsSliderTile extends StatelessWidget {
  const SettingsSliderTile({
    required this.title,
    required this.value,
    required this.divisions,
    required this.max,
    required this.onChanged,
    required this.onChangeEnd,
    super.key,
    this.min = 0.0,
    this.padding,
  });

  final String title;
  final double value;
  final int divisions;
  final double min;
  final double max;
  final void Function(double) onChanged;
  final void Function(double) onChangeEnd;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          padding ??
          const EdgeInsets.only(
            left: 16,
            right: 16,
          ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              title,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
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
