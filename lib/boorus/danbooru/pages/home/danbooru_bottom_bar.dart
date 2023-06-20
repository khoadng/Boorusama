// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/widgets/booru_bottom_bar.dart';

class DanbooruBottomBar extends StatelessWidget {
  const DanbooruBottomBar({
    super.key,
    required this.onTabChanged,
    this.initialValue = 0,
  });

  final ValueChanged<int> onTabChanged;
  final int initialValue;

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
          label: 'Explore',
          icon: currentIndex == 1
              ? const Icon(Icons.explore)
              : const Icon(Icons.explore_outlined),
        ),
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