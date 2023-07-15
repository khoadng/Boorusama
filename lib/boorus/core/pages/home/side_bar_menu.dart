// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/pages/home/switch_booru_modal.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
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
      width: width,
      content: SingleChildScrollView(
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
                icon: const Icon(Icons.manage_accounts),
                title: const Text('sideMenu.manage_boorus').tr(),
                onTap: () {
                  if (popOnSelect) context.navigator.pop();
                  context.go('/boorus');
                },
              ),
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
    );
  }
}

class CurrentBooruTile extends ConsumerWidget {
  const CurrentBooruTile({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watch(currentBooruConfigProvider);
    final booru = ref.watch(currentBooruProvider);

    return ListTile(
      horizontalTitleGap: 0,
      minLeadingWidth: 28,
      leading: switch (PostSource.from(booruConfig.url)) {
        WebSource s => BooruLogo(source: s),
        _ => null,
      },
      title: Wrap(
        children: [
          Text(
            booruConfig.isUnverified(booru)
                ? Uri.parse(booruConfig.url).host
                : booru.booruType.stringify(),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          if (booruConfig.ratingFilter != BooruConfigRatingFilter.none) ...[
            const SizedBox(width: 4),
            SquareChip(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              label: Text(
                booruConfig.ratingFilter.getRatingTerm().toUpperCase(),
                softWrap: true,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              color:
                  booruConfig.ratingFilter == BooruConfigRatingFilter.hideNSFW
                      ? Colors.green
                      : const Color.fromARGB(255, 154, 138, 0),
            ),
          ],
        ],
      ),
      subtitle: booruConfig.hasLoginDetails()
          ? Text(booruConfig.login ?? 'Unknown')
          : null,
      trailing: IconButton(
        onPressed: () {
          if (isMobilePlatform()) {
            showMaterialModalBottomSheet(
              context: context,
              duration: const Duration(milliseconds: 250),
              animationCurve: Curves.easeOut,
              builder: (context) => const SwitchBooruModal(),
            );
          } else {
            showSideSheetFromLeft(
              context: context,
              width: 300,
              body: Material(
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: SwitchBooruModal(),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        onPressed: () => context.navigator.pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
        icon: const Icon(Icons.more_vert),
      ),
    );
  }
}
