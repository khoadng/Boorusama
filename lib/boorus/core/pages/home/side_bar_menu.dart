// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/pages/boorus/booru_logo.dart';
import 'package:boorusama/boorus/core/pages/home/switch_booru_modal.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';

class SideBarMenu extends ConsumerWidget {
  const SideBarMenu({
    super.key,
    this.width,
    this.popOnSelect = false,
    this.initialContentBuilder,
    this.padding,
  });

  final double? width;
  final EdgeInsets? padding;
  final bool popOnSelect;
  final List<Widget>? Function(BuildContext context)? initialContentBuilder;

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
            Builder(
              builder: (context) {
                final booruConfig = ref.watch(currentBooruConfigProvider);
                final booru = ref.watch(currentBooruProvider);

                return ListTile(
                  horizontalTitleGap: 0,
                  minLeadingWidth: 28,
                  leading: BooruLogo(booru: booru),
                  title: Wrap(
                    children: [
                      Text(
                        booruConfig.isUnverified(booru)
                            ? booruConfig.url
                            : booru.booruType.stringify(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      if (booruConfig.ratingFilter !=
                          BooruConfigRatingFilter.none) ...[
                        const SizedBox(width: 4),
                        SquareChip(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4)),
                          label: Text(
                            booruConfig.ratingFilter
                                .getRatingTerm()
                                .toUpperCase(),
                            softWrap: true,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          color: booruConfig.ratingFilter ==
                                  BooruConfigRatingFilter.hideNSFW
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
                      showMaterialModalBottomSheet(
                        context: context,
                        duration: const Duration(milliseconds: 250),
                        animationCurve: Curves.easeOut,
                        builder: (context) => const SwitchBooruModal(),
                      );
                    },
                    icon: const Icon(Icons.more_vert),
                  ),
                );
              },
            ),
            if (initialContentBuilder != null) ...[
              ...initialContentBuilder!(context)!,
              const Divider(),
            ],
            const Divider(),
            _SideMenuTile(
              icon: const Icon(Icons.manage_accounts),
              title: const Text('sideMenu.manage_boorus').tr(),
              onTap: () {
                if (popOnSelect) Navigator.of(context).pop();
                context.go('/boorus');
              },
            ),
            _SideMenuTile(
              icon: const Icon(Icons.favorite),
              title: const Text('sideMenu.your_bookmarks').tr(),
              onTap: () {
                if (popOnSelect) Navigator.of(context).pop();
                context.go('/bookmarks');
              },
            ),
            _SideMenuTile(
              icon: const Icon(Icons.list_alt),
              title: const Text('sideMenu.your_blacklist').tr(),
              onTap: () {
                if (popOnSelect) Navigator.of(context).pop();
                goToGlobalBlacklistedTagsPage(context);
              },
            ),
            _SideMenuTile(
              icon: const Icon(Icons.download),
              title: const Text('sideMenu.bulk_download').tr(),
              onTap: () {
                if (popOnSelect) Navigator.of(context).pop();
                goToBulkDownloadPage(
                  context,
                  null,
                  ref: ref,
                );
              },
            ),
            _SideMenuTile(
              icon: const Icon(Icons.settings_outlined),
              title: Text('sideMenu.settings'.tr()),
              onTap: () {
                if (popOnSelect) Navigator.of(context).pop();
                context.go('/settings');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SideMenuTile extends StatelessWidget {
  const _SideMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final Widget icon;
  final Widget title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        child: ListTile(
          leading: icon,
          title: title,
          onTap: onTap,
        ),
      ),
    );
  }
}
