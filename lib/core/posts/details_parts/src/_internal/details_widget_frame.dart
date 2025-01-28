// Flutter imports:
import 'package:flutter/material.dart';

class DetailsWidgetSeparator extends StatelessWidget {
  const DetailsWidgetSeparator({
    required this.child,
    super.key,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.15,
          ),
        ),
      ),
      child: child,
    );
  }
}
