// Flutter imports:
import 'package:flutter/material.dart';

class SideMenuTile extends StatelessWidget {
  const SideMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    super.key,
    this.popOnSelect = true,
  });

  final Widget icon;
  final Widget title;
  final VoidCallback onTap;
  final bool popOnSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (popOnSelect) {
            Navigator.of(context).pop();
          }

          onTap();
        },
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.titleSmall ?? const TextStyle(),
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
