// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/widgets/booru_selector.dart';
import 'package:boorusama/boorus/core/widgets/current_booru_tile.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';
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
    return SideBar(
      width: min(context.screenWidth * 0.8, 500),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SafeArea(child: BooruSelector()),
          const VerticalDivider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).viewPadding.top,
                  ),
                  const CurrentBooruTile(),
                  if (initialContentBuilder != null) ...[
                    ...initialContentBuilder!(context)!,
                  ],
                  const Divider(),
                  if (contentBuilder != null) ...[
                    ...contentBuilder!(context),
                  ] else ...[
                    SideMenuTile(
                      icon: const Icon(Icons.favorite),
                      title: const Text('sideMenu.your_bookmarks').tr(),
                      onTap: () {
                        if (popOnSelect) context.navigator.pop();
                        context.go('/bookmarks');
                      },
                    ),
                    SideMenuTile(
                      icon: const Icon(Icons.list_alt),
                      title: const Text('sideMenu.your_blacklist').tr(),
                      onTap: () {
                        if (popOnSelect) context.navigator.pop();
                        goToGlobalBlacklistedTagsPage(context);
                      },
                    ),
                    SideMenuTile(
                      icon: const Icon(Icons.download),
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
                      icon: const Icon(Icons.settings_outlined),
                      title: Text('sideMenu.settings'.tr()),
                      onTap: () {
                        if (popOnSelect) context.navigator.pop();
                        context.go('/settings');
                      },
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
