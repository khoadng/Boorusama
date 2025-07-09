// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../theme.dart';

class MultiSelectButton extends StatelessWidget {
  const MultiSelectButton({
    required this.icon,
    required this.name,
    required this.onPressed,
    this.width,
    this.maxLines,
    this.mainAxisAlignment,
    super.key,
  });

  final Widget icon;
  final String name;
  final int? maxLines;
  final double? width;
  final MainAxisAlignment? mainAxisAlignment;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconTheme = IconTheme.of(context);

    return InkWell(
      hoverColor: Theme.of(context).hoverColor.withValues(alpha: 0.1),
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onTap: onPressed,
      child: SizedBox(
        width: width ?? 100,
        child: Column(
          mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
          children: [
            const SizedBox(height: 4),
            Theme(
              data: ThemeData(
                iconTheme: iconTheme.copyWith(
                  color: onPressed != null
                      ? colorScheme.onSurface
                      : colorScheme.hintColor,
                ),
              ),
              child: icon,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(
                left: 4,
                right: 4,
                bottom: 4,
              ),
              child: Text(
                name,
                textAlign: TextAlign.center,
                maxLines: maxLines ?? 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: onPressed != null ? null : colorScheme.hintColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
