// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/widgets/booru_bottom_bar.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/widgets/navigation_tile.dart';

class MoebooruBottomBar extends StatelessWidget {
  const MoebooruBottomBar({
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
              BottomNavigationBarItem(
                label: 'Hot',
                icon: currentIndex == 2
                    ? const Icon(Icons.local_fire_department)
                    : const Icon(Icons.local_fire_department_outlined),
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
                title: const Text('Popular'),
                onTap: onTabChanged,
              ),
              NavigationTile(
                value: 2,
                index: initialValue,
                selectedIcon: const Icon(Icons.local_fire_department),
                icon: const Icon(Icons.local_fire_department_outlined),
                title: const Text('Hot'),
                onTap: onTabChanged,
              ),
            ],
          );
  }
}
