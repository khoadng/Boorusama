// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../blacklists/routes.dart';
import '../bookmarks/routes.dart';
import '../bulk_downloads/routes.dart';
import '../configs/config/providers.dart';
import '../configs/manage/widgets.dart';
import '../downloads/routes.dart';
import '../premiums/premiums.dart';
import '../premiums/providers.dart';
import '../premiums/routes.dart';
import '../search/search/routes.dart';
import '../settings/providers.dart';
import '../settings/routes.dart';
import '../settings/settings.dart';
import '../tags/favorites/routes.dart';
import 'constants.dart';
import 'custom_home.dart';
import 'side_menu_tile.dart';

class SideBarMenu extends ConsumerWidget {
  const SideBarMenu({
    super.key,
    this.width,
    this.initialContent,
    this.content,
    this.padding,
  });

  final double? width;
  final EdgeInsets? padding;
  final List<Widget>? initialContent;
  final List<Widget>? content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(
      settingsProvider.select((value) => value.booruConfigSelectorPosition),
    );
    final viewKey = ref.watch(customHomeViewKeyProvider);
    final hasPremium = ref.watch(hasPremiumProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final hasConfigs = ref.watch(hasBooruConfigsProvider);

    return Container(
      color: colorScheme.surfaceContainerLow,
      constraints: BoxConstraints.expand(
        width: min(MediaQuery.sizeOf(context).width * 0.85, 400),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (position == BooruConfigSelectorPosition.side)
            ColoredBox(
              color: colorScheme.surface,
              child: const SafeArea(
                bottom: false,
                child: BooruSelector(),
              ),
            ),
          VerticalDivider(
            color: colorScheme.outlineVariant,
            thickness: 0.25,
            width: 1,
          ),
          Expanded(
            child: ColoredBox(
              color: colorScheme.surfaceContainerLow,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (initialContent != null)
                      SizedBox(
                        height: viewPadding.top,
                      )
                    else
                      const SizedBox(height: 28),
                    if (hasConfigs)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: CurrentBooruTile(
                          minWidth: kMinSideBarWidth,
                        ),
                      )
                    else
                      const SizedBox(
                        height: 24,
                      ),
                    if (initialContent != null)
                      ...initialContent!.map(
                        (e) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: e,
                        ),
                      ),
                    if (initialContent != null)
                      const Divider(
                        thickness: 0.75,
                      ),
                    if (content != null) ...[
                      ...content!.map(
                        (e) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: e,
                        ),
                      ),
                    ] else
                      ...[
                        if (viewKey != null && viewKey.isAlt)
                          SideMenuTile(
                            icon: const Icon(Symbols.search),
                            title: const Text('settings.search.search').tr(),
                            onTap: () {
                              goToSearchPage(context);
                            },
                          ),
                        SideMenuTile(
                          icon: const Icon(Symbols.favorite),
                          title: const Text('sideMenu.your_bookmarks').tr(),
                          onTap: () {
                            goToBookmarkPage(context);
                          },
                        ),
                        SideMenuTile(
                          icon: const Icon(Symbols.list),
                          title: const Text('sideMenu.your_blacklist').tr(),
                          onTap: () {
                            goToGlobalBlacklistedTagsPage(context);
                          },
                        ),
                        SideMenuTile(
                          icon: const Icon(Symbols.tag),
                          title: const Text('favorite_tags.favorite_tags').tr(),
                          onTap: () {
                            goToFavoriteTagsPage(context);
                          },
                        ),
                        SideMenuTile(
                          icon: const Icon(Symbols.sim_card_download),
                          title: const Text('sideMenu.bulk_download').tr(),
                          onTap: () {
                            goToBulkDownloadPage(
                              context,
                              null,
                              ref: ref,
                            );
                          },
                        ),
                        SideMenuTile(
                          icon: const Icon(Symbols.download),
                          title: const Text('Download manager'),
                          onTap: () {
                            goToDownloadManagerPage(context);
                          },
                        ),
                        const Divider(
                          key: ValueKey('divider'),
                          thickness: 0.75,
                        ),
                        if (kPremiumEnabled && !kForcePremium && !hasPremium)
                          SideMenuTile(
                            icon: const Icon(
                              Symbols.favorite,
                              fill: 1,
                              color: Colors.red,
                            ),
                            title: const Text('Get $kPremiumBrandName'),
                            onTap: () {
                              goToPremiumPage(context);
                            },
                          ),
                        SideMenuTile(
                          icon: const Icon(
                            Symbols.question_mark,
                            fill: 1,
                          ),
                          title: const Text('sideMenu.get_support').tr(),
                          onTap: () {
                            goToSettingsPage(context, scrollTo: 'support');
                          },
                        ),
                        SideMenuTile(
                          icon: const Icon(
                            Symbols.settings,
                            fill: 1,
                          ),
                          title: Text('sideMenu.settings'.tr()),
                          onTap: () {
                            goToSettingsPage(context);
                          },
                        ),
                      ].map(
                        (e) => Padding(
                          padding: e.key != const ValueKey('divider')
                              ? const EdgeInsets.symmetric(horizontal: 8)
                              : EdgeInsets.zero,
                          child: e,
                        ),
                      ),
                    SizedBox(
                      height: viewPadding.bottom + 12,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
