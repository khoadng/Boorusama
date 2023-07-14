// Flutter imports:
import 'package:flutter/material.dart';

class NavigationTile extends StatelessWidget {
  const NavigationTile({
    super.key,
    required this.value,
    required this.index,
    required this.selectedIcon,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final int index;
  final int value;
  final Widget selectedIcon;
  final Widget icon;
  final Widget title;
  final void Function(int value) onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: index == value
          ? Theme.of(context).colorScheme.primary
          : Colors.transparent,
      child: InkWell(
        child: ListTile(
          textColor: index == value ? Colors.white : null,
          leading: index == value ? selectedIcon : icon,
          title: title,
          onTap: () => onTap(value),
        ),
      ),
    );
  }
}
