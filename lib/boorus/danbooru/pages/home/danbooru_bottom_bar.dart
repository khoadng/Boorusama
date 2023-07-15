// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/widgets/booru_bottom_bar.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/router.dart';
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
        : Theme(
            data: context.theme.copyWith(
              iconTheme: context.theme.iconTheme.copyWith(size: 20),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  NavigationTile(
                    value: 0,
                    index: initialValue,
                    showIcon: constraints.maxWidth > 200 ||
                        constraints.maxWidth <= 62,
                    showTitle: constraints.maxWidth > 62,
                    selectedIcon: const Icon(Icons.dashboard),
                    icon: const Icon(
                      Icons.dashboard_outlined,
                    ),
                    title: const Text(
                      'Home',
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: onTabChanged,
                  ),
                  NavigationTile(
                    value: 1,
                    index: initialValue,
                    showIcon: constraints.maxWidth > 200 ||
                        constraints.maxWidth <= 62,
                    showTitle: constraints.maxWidth > 62,
                    selectedIcon: const Icon(Icons.explore),
                    icon: const Icon(Icons.explore_outlined),
                    title: const Text(
                      'Explore',
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: onTabChanged,
                  ),
                  NavigationTile(
                    value: 2,
                    index: initialValue,
                    showIcon: constraints.maxWidth > 200 ||
                        constraints.maxWidth <= 62,
                    showTitle: constraints.maxWidth > 62,
                    selectedIcon: const Icon(Icons.search),
                    icon: const Icon(Icons.search_outlined),
                    title: const Text(
                      'Search',
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: onTabChanged,
                  ),
                  NavigationTile(
                    value: 3,
                    index: initialValue,
                    showIcon: constraints.maxWidth > 200 ||
                        constraints.maxWidth <= 62,
                    showTitle: constraints.maxWidth > 62,
                    selectedIcon: const Icon(Icons.photo_album),
                    icon: const Icon(Icons.photo_album_outlined),
                    title: const Text(
                      'Pools',
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: onTabChanged,
                  ),
                  NavigationTile(
                    value: 4,
                    index: initialValue,
                    showIcon: constraints.maxWidth > 200 ||
                        constraints.maxWidth <= 62,
                    showTitle: constraints.maxWidth > 62,
                    selectedIcon: const Icon(Icons.forum),
                    icon: const Icon(Icons.forum_outlined),
                    title: const Text(
                      'forum.forum',
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).tr(),
                    onTap: onTabChanged,
                  ),
                  NavigationTile(
                    value: 5,
                    index: initialValue,
                    showIcon: constraints.maxWidth > 200 ||
                        constraints.maxWidth <= 62,
                    showTitle: constraints.maxWidth > 62,
                    selectedIcon: const Icon(Icons.favorite),
                    icon: const Icon(Icons.favorite_border_outlined),
                    title: const Text(
                      'Favorites',
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: onTabChanged,
                  ),
                  NavigationTile(
                    value: 6,
                    index: initialValue,
                    showIcon: constraints.maxWidth > 200 ||
                        constraints.maxWidth <= 62,
                    showTitle: constraints.maxWidth > 62,
                    selectedIcon: const Icon(Icons.collections),
                    icon: const Icon(Icons.collections_outlined),
                    title: const Text(
                      'favorite_groups.favorite_groups',
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).tr(),
                    onTap: onTabChanged,
                  ),
                  NavigationTile(
                    value: 7,
                    index: initialValue,
                    showIcon: constraints.maxWidth > 200 ||
                        constraints.maxWidth <= 62,
                    showTitle: constraints.maxWidth > 62,
                    selectedIcon: const Icon(Icons.saved_search),
                    icon: const Icon(Icons.save_alt_outlined),
                    title: const Text(
                      'saved_search.saved_search',
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).tr(),
                    onTap: onTabChanged,
                  ),
                  NavigationTile(
                    value: 8,
                    index: initialValue,
                    showIcon: constraints.maxWidth > 200 ||
                        constraints.maxWidth <= 62,
                    showTitle: constraints.maxWidth > 62,
                    selectedIcon: const Icon(Icons.tag),
                    icon: const Icon(Icons.tag_outlined),
                    title: const Text(
                      'blacklisted_tags.blacklisted_tags',
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).tr(),
                    onTap: onTabChanged,
                  ),
                  const Divider(),
                  NavigationTile(
                    value: 9,
                    index: initialValue,
                    showIcon: constraints.maxWidth > 200 ||
                        constraints.maxWidth <= 62,
                    showTitle: constraints.maxWidth > 62,
                    selectedIcon: const Icon(Icons.bookmark),
                    icon: const Icon(Icons.bookmark_border_outlined),
                    title: const Text(
                      'sideMenu.your_bookmarks',
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).tr(),
                    onTap: onTabChanged,
                  ),
                  NavigationTile(
                    value: 10,
                    index: initialValue,
                    showIcon: constraints.maxWidth > 200 ||
                        constraints.maxWidth <= 62,
                    showTitle: constraints.maxWidth > 62,
                    selectedIcon: const Icon(Icons.list_alt),
                    icon: const Icon(Icons.list_alt_outlined),
                    title: const Text(
                      'sideMenu.your_blacklist',
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).tr(),
                    onTap: onTabChanged,
                  ),
                  NavigationTile(
                    value: 11,
                    index: initialValue,
                    showIcon: constraints.maxWidth > 200 ||
                        constraints.maxWidth <= 62,
                    showTitle: constraints.maxWidth > 62,
                    selectedIcon: const Icon(Icons.download),
                    icon: const Icon(Icons.download_outlined),
                    title: const Text(
                      'sideMenu.bulk_download',
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).tr(),
                    onTap: onTabChanged,
                  ),
                  const Divider(),
                  NavigationTile(
                    value: 999,
                    index: 9999,
                    showIcon: constraints.maxWidth > 200 ||
                        constraints.maxWidth <= 62,
                    showTitle: constraints.maxWidth > 62,
                    selectedIcon: const Icon(Icons.settings),
                    icon: const Icon(Icons.settings),
                    title: Text('sideMenu.settings'.tr()),
                    onTap: (_) {
                      context.go('/settings');
                    },
                  ),
                ],
              ),
            ),
          );
  }
}
