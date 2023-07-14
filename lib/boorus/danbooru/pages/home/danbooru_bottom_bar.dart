// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/widgets/booru_bottom_bar.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/widgets/navigation_tile.dart';
import 'other_features_page.dart';

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
    return isMobilePlatform()
        ? BooruBottomBar(
            onTabChanged: (value) {
              onTabChanged(value);
            },
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
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NavigationTile(
                value: 0,
                index: initialValue,
                selectedIcon: const Icon(Icons.dashboard),
                icon: const Icon(
                  Icons.dashboard_outlined,
                ),
                title: const Text('Home'),
                onTap: onTabChanged,
              ),
              NavigationTile(
                value: 1,
                index: initialValue,
                selectedIcon: const Icon(Icons.explore),
                icon: const Icon(Icons.explore_outlined),
                title: const Text('Explore'),
                onTap: onTabChanged,
              ),
              const Divider(),
              const DanbooruOtherFeaturesWidget(),
            ],
          );
  }
}
