// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/theme.dart';

class SideMenuTile extends StatelessWidget {
  const SideMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final Widget icon;
  final Widget title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: DefaultTextStyle(
          style: context.textTheme.titleSmall ?? const TextStyle(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),
                icon,
                const SizedBox(width: 12),
                title,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
