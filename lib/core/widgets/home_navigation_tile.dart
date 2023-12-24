// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/entry_page.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/navigation_tile.dart';

class HomeNavigationTile extends StatelessWidget {
  const HomeNavigationTile({
    super.key,
    this.onTap,
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.value,
    required this.constraints,
    required this.controller,
  });

  // Will override the onTap function
  final VoidCallback? onTap;
  final String title;
  final IconData icon;
  final IconData selectedIcon;
  final int value;
  final BoxConstraints constraints;
  final HomePageController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, index, child) {
        final selected = value == index;

        return NavigationTile(
          value: value,
          index: index,
          showIcon: constraints.maxWidth > 200 || constraints.maxWidth <= 62,
          showTitle: constraints.maxWidth > 62,
          selectedIcon: Icon(
            selected ? selectedIcon : icon,
            fill: 1,
            color: selected ? context.colorScheme.onSecondary : null,
          ),
          icon: Icon(
            icon,
            color: selected ? context.colorScheme.onSecondary : null,
          ),
          title: Text(
            title,
            softWrap: false,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? context.colorScheme.onSecondary : null,
            ),
          ),
          onTap: (value) =>
              onTap != null ? onTap!() : controller.goToTab(value),
        );
      },
    );
  }
}
