// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../themes/theme/types.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({
    required this.child,
    super.key,
    this.onTap,
    this.margin,
    this.padding,
    this.title,
    this.trailing,
  });

  final Widget child;
  final void Function()? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final String? title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final title = this.title;

    return Container(
      margin:
          margin ??
          const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(
                bottom: 8,
              ),
              child: Row(
                children: [
                  Text(
                    title.toUpperCase(),
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.hintColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (trailing != null) ...[
                    trailing!,
                  ],
                ],
              ),
            ),
          Material(
            color: colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: onTap,
              child: Container(
                padding:
                    padding ??
                    const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
