// Flutter imports:
import 'package:flutter/material.dart';

class ProgressStepper extends StatelessWidget {
  const ProgressStepper({
    required this.current,
    required this.max,
    required this.color,
    super.key,
  });

  final int current;
  final int max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: current / max,
        color: color,
        minHeight: 8,
      ),
    );
  }
}
