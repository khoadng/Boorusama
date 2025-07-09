// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../theme.dart';

class BackupRestoreTile extends StatelessWidget {
  const BackupRestoreTile({
    required this.leadingIcon,
    required this.title,
    required this.trailing,
    super.key,
    this.subtitle,
    this.subtitleStyle,
    this.extra,
  });

  final IconData leadingIcon;
  final String title;
  final String? subtitle;
  final TextStyle? subtitleStyle;
  final Widget trailing;
  final List<Widget>? extra;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: Icon(
              leadingIcon,
              color: Theme.of(context).colorScheme.onSurface,
              fill: 1,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style:
                        subtitleStyle ??
                        TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.hintColor,
                        ),
                  ),
                if (extra != null) ...extra!,
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
