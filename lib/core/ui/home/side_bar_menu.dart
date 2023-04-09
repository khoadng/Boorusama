// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/blacklists/blacklisted_tag_page.dart';
import 'package:boorusama/core/ui/boorus/booru_logo.dart';
import 'package:boorusama/core/ui/home/current_booru_action_sheet.dart';
import 'package:boorusama/core/ui/side_bar.dart';
import 'package:boorusama/core/ui/widgets/square_chip.dart';

class SideBarMenu extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SideBar(
      width: width,
      content: SingleChildScrollView(
        child: BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).viewPadding.top,
                ),
                BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
                  builder: (context, state) {
                    return state.booru != null
                        ? ListTile(
                            horizontalTitleGap: 0,
                            minLeadingWidth: 28,
                            leading: BooruLogo(booru: state.booru!),
                            title: Wrap(
                              children: [
                                Text(
                                  state.booru!.booruType.stringify(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  ),
                                ),
                                if (state.booruConfig != null &&
                                    state.booruConfig!.ratingFilter !=
                                        BooruConfigRatingFilter.none) ...[
                                  const SizedBox(width: 4),
                                  SquareChip(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(4)),
                                    label: Text(
                                      state.booruConfig!.ratingFilter
                                          .getRatingTerm()
                                          .toUpperCase(),
                                      softWrap: true,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    color: state.booruConfig!.ratingFilter ==
                                            BooruConfigRatingFilter.hideNSFW
                                        ? Colors.green
                                        : const Color.fromARGB(
                                            255, 154, 138, 0),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: state.booruConfig.hasLoginDetails()
                                ? Text(state.booruConfig!.login ?? 'Unknown')
                                : null,
                            trailing: IconButton(
                              onPressed: () => showMaterialModalBottomSheet(
                                context: context,
                                builder: (context) =>
                                    const CurrentBooruActionSheet(),
                              ),
                              icon: const Icon(Icons.more_vert),
                            ),
                          )
                        : const SizedBox.shrink();
                  },
                ),
                if (initialContentBuilder != null) ...[
                  ...initialContentBuilder!(context)!,
                  const Divider(),
                ],
                const Divider(),
                _SideMenuTile(
                  icon: const Icon(Icons.manage_accounts),
                  title: const Text('Manage sources'),
                  onTap: () {
                    if (popOnSelect) Navigator.of(context).pop();
                    goToManageBooruPage(context);
                  },
                ),
                _SideMenuTile(
                  icon: const Icon(Icons.favorite),
                  title: const Text('Your Bookmarks'),
                  onTap: () {
                    if (popOnSelect) Navigator.of(context).pop();
                    goToBookmarkPage(context);
                  },
                ),
                _SideMenuTile(
                  icon: const Icon(Icons.list_alt),
                  title: const Text('Your Blacklist'),
                  onTap: () {
                    if (popOnSelect) Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const BlacklistedTagPage()));
                  },
                ),
                _SideMenuTile(
                  icon: const Icon(Icons.settings_outlined),
                  title: Text('sideMenu.settings'.tr()),
                  onTap: () {
                    if (popOnSelect) Navigator.of(context).pop();
                    goToSettingPage(context);
                  },
                ),
              ],
            );
          },
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
