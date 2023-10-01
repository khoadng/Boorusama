// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/entry_page.dart';
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
  final Widget icon;
  final Widget selectedIcon;
  final int value;
  final BoxConstraints constraints;
  final HomePageController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, index, child) => NavigationTile(
        value: value,
        index: index,
        showIcon: constraints.maxWidth > 200 || constraints.maxWidth <= 62,
        showTitle: constraints.maxWidth > 62,
        selectedIcon: selectedIcon,
        icon: icon,
        title: Text(
          title,
          softWrap: false,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: (value) => onTap != null ? onTap!() : controller.goToTab(value),
      ),
    );
  }
}
