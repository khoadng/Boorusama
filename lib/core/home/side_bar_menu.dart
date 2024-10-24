// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/manage/booru_selector.dart';
import 'package:boorusama/core/configs/manage/current_booru_tile.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/router.dart';
import 'side_menu_tile.dart';

class SideBarMenu extends ConsumerWidget {
  const SideBarMenu({
    super.key,
    this.width,
    this.popOnSelect = false,
    this.initialContent,
    this.content,
    this.padding,
  });

  final double? width;
  final EdgeInsets? padding;
  final bool popOnSelect;
  final List<Widget>? initialContent;
  final List<Widget>? content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(
        settingsProvider.select((value) => value.booruConfigSelectorPosition));

    return Container(
      color: context.colorScheme.surface,
      constraints:
          BoxConstraints.expand(width: min(context.screenWidth * 0.85, 500)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (position == BooruConfigSelectorPosition.side)
            ColoredBox(
              color: context.colorScheme.secondaryContainer,
              child: const SafeArea(
                bottom: false,
                child: BooruSelector(),
              ),
            ),
          Expanded(
            child: ColoredBox(
              color: context.colorScheme.surface,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (initialContent != null)
                      SizedBox(
                        height: MediaQuery.viewPaddingOf(context).top,
                      )
                    else
                      const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: CurrentBooruTile(),
                    ),
                    if (initialContent != null)
                      ...initialContent!.map((e) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: e,
                          )),
                    if (initialContent != null) const Divider(),
                    if (content != null) ...[
                      ...content!.map((e) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: e,
                          )),
                    ] else
                      ...[
                        SideMenuTile(
                          icon: const Icon(Symbols.favorite),
                          title: const Text('sideMenu.your_bookmarks').tr(),
                          onTap: () {
                            if (popOnSelect) context.navigator.pop();
                            context.go('/bookmarks');
                          },
                        ),
                        SideMenuTile(
                          icon: const Icon(Symbols.list),
                          title: const Text('sideMenu.your_blacklist').tr(),
                          onTap: () {
                            if (popOnSelect) context.navigator.pop();
                            context.go('/global_blacklisted_tags');
                          },
                        ),
                        SideMenuTile(
                          icon: const Icon(Symbols.tag),
                          title: const Text('favorite_tags.favorite_tags').tr(),
                          onTap: () {
                            if (popOnSelect) context.navigator.pop();
                            context.go('/favorite_tags');
                          },
                        ),
                        SideMenuTile(
                          icon: const Icon(Symbols.sim_card_download),
                          title: const Text('sideMenu.bulk_download').tr(),
                          onTap: () {
                            if (popOnSelect) context.navigator.pop();
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
                            if (popOnSelect) context.navigator.pop();
                            context.go('/download_manager');
                          },
                        ),
                        const Divider(
                          key: ValueKey('divider'),
                        ),
                        SideMenuTile(
                          icon: const Icon(
                            Symbols.question_mark,
                            fill: 1,
                          ),
                          title: const Text('sideMenu.get_support').tr(),
                          onTap: () {
                            if (popOnSelect) context.navigator.pop();
                            context.go('/settings?scrollTo=support');
                          },
                        ),
                        SideMenuTile(
                          icon: const Icon(
                            Symbols.settings,
                            fill: 1,
                          ),
                          title: Text('sideMenu.settings'.tr()),
                          onTap: () {
                            if (popOnSelect) context.navigator.pop();
                            context.go('/settings');
                          },
                        ),
                      ].map((e) => Padding(
                            padding: e.key != const ValueKey('divider')
                                ? const EdgeInsets.symmetric(horizontal: 8)
                                : EdgeInsets.zero,
                            child: e,
                          )),
                    SizedBox(
                      height: MediaQuery.viewPaddingOf(context).bottom + 12,
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
