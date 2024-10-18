// Flutter imports:
import 'package:flutter/material.dart';

class PerformanceOrientationBuilder extends StatelessWidget {
  const PerformanceOrientationBuilder({
    super.key,
    required this.builder,
  });

  final OrientationWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.orientationOf(context);

    return builder(context, orientation);
  }
}
