// Flutter imports:
import 'package:flutter/material.dart';

class IconTextButton extends StatelessWidget {
  const IconTextButton({
    super.key,
    this.width,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final double? width;
  final Widget icon;
  final Widget label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      padding: EdgeInsets.zero,
      visualDensity: const VisualDensity(horizontal: -4),
      onPressed: onPressed,
      child: SizedBox(
        child: Wrap(
          runAlignment: WrapAlignment.center,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            icon,
            const SizedBox(width: 2),
            label,
          ],
        ),
      ),
    );
  }
}
