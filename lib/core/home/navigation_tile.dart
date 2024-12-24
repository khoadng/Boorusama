// Flutter imports:
import 'package:flutter/material.dart';

class NavigationTile extends StatelessWidget {
  const NavigationTile({
    required this.value,
    required this.index,
    required this.selectedIcon,
    required this.icon,
    required this.title,
    required this.onTap,
    super.key,
    this.showIcon = true,
    this.showTitle = true,
  });

  final int index;
  final int value;
  final Widget selectedIcon;
  final Widget icon;
  final Widget title;
  final void Function(int value) onTap;
  final bool showIcon;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final selected = index == value;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 2,
      ),
      child: Material(
        borderRadius: BorderRadius.circular(4),
        color: selected
            ? Theme.of(context).colorScheme.secondary
            : Colors.transparent,
        child: InkWell(
          hoverColor: Theme.of(context).hoverColor.withAlpha(25),
          borderRadius: BorderRadius.circular(4),
          onTap: () => onTap(value),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding:
                EdgeInsets.symmetric(horizontal: 8, vertical: showIcon ? 4 : 6),
            child: showIcon && showTitle
                ? Row(
                    children: [
                      if (selected) selectedIcon else icon,
                      const SizedBox(width: 16),
                      Expanded(child: title),
                    ],
                  )
                : showIcon
                    ? selected
                        ? selectedIcon
                        : icon
                    : title,
          ),
        ),
      ),
    );
  }
}
