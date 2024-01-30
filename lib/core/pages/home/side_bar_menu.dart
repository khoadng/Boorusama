// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/widgets/booru_selector.dart';
import 'package:boorusama/core/widgets/current_booru_tile.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/router.dart';
import 'side_menu_tile.dart';

class SideBarMenu extends ConsumerWidget {
  const SideBarMenu({
    super.key,
    this.width,
    this.popOnSelect = false,
    this.initialContentBuilder,
    this.contentBuilder,
    this.padding,
  });

  final double? width;
  final EdgeInsets? padding;
  final bool popOnSelect;
  final List<Widget>? Function(BuildContext context)? initialContentBuilder;
  final List<Widget> Function(BuildContext context)? contentBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: context.colorScheme.surface,
      constraints:
          BoxConstraints.expand(width: min(context.screenWidth * 0.85, 500)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.viewPaddingOf(context).top,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: CurrentBooruTile(),
                    ),
                    if (initialContentBuilder != null)
                      ...[
                        ...initialContentBuilder!(context)!,
                      ].map((e) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: e,
                          )),
                    const Divider(),
                    if (contentBuilder != null) ...[
                      ...contentBuilder!(context).map((e) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: e,
                          ))
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
                          title: const Text('Favorite tags'),
                          onTap: () {
                            if (popOnSelect) context.navigator.pop();
                            context.go('/favorite_tags');
                          },
                        ),
                        SideMenuTile(
                          icon: const Icon(Symbols.download),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: e,
                          )),
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
