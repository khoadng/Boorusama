// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/widgets/booru_bottom_bar.dart';

class E621BottomBar extends StatelessWidget {
  const E621BottomBar({
    super.key,
    required this.onTabChanged,
    this.initialValue = 0,
    this.isAuthenticated = false,
  });

  final ValueChanged<int> onTabChanged;
  final int initialValue;
  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    return BooruBottomBar(
      onTabChanged: onTabChanged,
      items: (currentIndex) => [
        BottomNavigationBarItem(
          label: 'Home',
          icon: currentIndex == 0
              ? const Icon(Icons.dashboard)
              : const Icon(Icons.dashboard_outlined),
        ),
        BottomNavigationBarItem(
          label: 'Popular',
          icon: currentIndex == 1
              ? const Icon(Icons.explore)
              : const Icon(Icons.explore_outlined),
        ),
        if (isAuthenticated)
          BottomNavigationBarItem(
            label: 'More',
            icon: currentIndex == 2
                ? const Icon(Icons.more_horiz)
                : const Icon(Icons.more_horiz_outlined),
          ),
      ],
    );
  }
}
