// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/widgets/booru_bottom_bar.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/widgets/navigation_tile.dart';

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
              NavigationTile(
                value: 2,
                index: initialValue,
                selectedIcon: const Icon(Icons.search),
                icon: const Icon(Icons.search_outlined),
                title: const Text('Search'),
                onTap: onTabChanged,
              ),
              NavigationTile(
                value: 3,
                index: initialValue,
                selectedIcon: const Icon(Icons.photo_album),
                icon: const Icon(Icons.photo_album_outlined),
                title: const Text('Pools'),
                onTap: onTabChanged,
              ),
              NavigationTile(
                value: 4,
                index: initialValue,
                selectedIcon: const Icon(Icons.forum),
                icon: const Icon(Icons.forum_outlined),
                title: const Text('forum.forum').tr(),
                onTap: onTabChanged,
              ),
              NavigationTile(
                value: 5,
                index: initialValue,
                selectedIcon: const Icon(Icons.favorite),
                icon: const Icon(Icons.favorite_border_outlined),
                title: const Text('Favorites'),
                onTap: onTabChanged,
              ),
              NavigationTile(
                value: 6,
                index: initialValue,
                selectedIcon: const Icon(Icons.collections),
                icon: const Icon(Icons.collections_outlined),
                title: const Text('favorite_groups.favorite_groups').tr(),
                onTap: onTabChanged,
              ),
              NavigationTile(
                value: 7,
                index: initialValue,
                selectedIcon: const Icon(Icons.saved_search),
                icon: const Icon(Icons.save_alt_outlined),
                title: const Text('saved_search.saved_search').tr(),
                onTap: onTabChanged,
              ),
              NavigationTile(
                value: 8,
                index: initialValue,
                selectedIcon: const Icon(Icons.tag),
                icon: const Icon(Icons.tag_outlined),
                title: const Text('blacklisted_tags.blacklisted_tags').tr(),
                onTap: onTabChanged,
              ),
              const Divider(),
              NavigationTile(
                value: 9,
                index: initialValue,
                selectedIcon: const Icon(Icons.manage_accounts),
                icon: const Icon(Icons.manage_accounts_outlined),
                title: const Text('sideMenu.manage_boorus').tr(),
                onTap: onTabChanged,
              ),
              NavigationTile(
                value: 10,
                index: initialValue,
                selectedIcon: const Icon(Icons.bookmark),
                icon: const Icon(Icons.bookmark_border_outlined),
                title: const Text('sideMenu.your_bookmarks').tr(),
                onTap: onTabChanged,
              ),
              NavigationTile(
                value: 11,
                index: initialValue,
                selectedIcon: const Icon(Icons.list_alt),
                icon: const Icon(Icons.list_alt_outlined),
                title: const Text('sideMenu.your_blacklist').tr(),
                onTap: onTabChanged,
              ),
              NavigationTile(
                value: 12,
                index: initialValue,
                selectedIcon: const Icon(Icons.download),
                icon: const Icon(Icons.download_outlined),
                title: const Text('sideMenu.bulk_download').tr(),
                onTap: onTabChanged,
              ),
            ],
          );
  }
}
