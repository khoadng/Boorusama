// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/account/account.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/ui/side_bar.dart';

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
        child: BlocBuilder<AccountCubit, AsyncLoadState<Account>>(
          builder: (context, state) {
            return state.status == LoadStatus.success
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).viewPadding.top,
                      ),
                      if (initialContentBuilder != null) ...[
                        ...initialContentBuilder!(context)!,
                        const Divider(),
                      ],
                      if (state.data! == Account.empty)
                        _SideMenuTile(
                          icon: const Icon(Icons.login_outlined),
                          title: Text('sideMenu.login'.tr()),
                          onTap: () {
                            if (popOnSelect) Navigator.of(context).pop();
                            goToLoginPage(context);
                          },
                        )
                      else
                        _SideMenuTile(
                          icon: const Icon(Icons.person_outline),
                          title: Text('sideMenu.profile'.tr()),
                          onTap: () {
                            if (popOnSelect) Navigator.of(context).pop();
                            goToProfilePage(context);
                          },
                        ),
                      if (state.data! != Account.empty)
                        _SideMenuTile(
                          icon: const Icon(Icons.favorite_outline),
                          title: Text('profile.favorites'.tr()),
                          onTap: () {
                            if (popOnSelect) Navigator.of(context).pop();
                            goToFavoritesPage(context, state.data!.username);
                          },
                        ),
                      if (state.data! != Account.empty)
                        ListTile(
                          leading: const Icon(Icons.collections),
                          title: const Text('Favorite groups'),
                          onTap: () {
                            if (popOnSelect) Navigator.of(context).pop();
                            AppRouter.router.navigateTo(
                              context,
                              '/favorite_groups',
                              // routeSettings: RouteSettings(arguments: []),
                              transition:
                                  Screen.of(context).size == ScreenSize.small
                                      ? TransitionType.inFromRight
                                      : null,
                            );
                          },
                        ),
                      if (state.data! != Account.empty)
                        _SideMenuTile(
                          icon: const Icon(Icons.search),
                          title: const Text('Saved search'),
                          onTap: () {
                            if (popOnSelect) Navigator.of(context).pop();
                            goToSavedSearchPage(context, state.data!.username);
                          },
                        ),
                      if (state.data! != Account.empty)
                        _SideMenuTile(
                          icon: const FaIcon(FontAwesomeIcons.ban, size: 20),
                          title: const Text(
                            'blacklisted_tags.blacklisted_tags',
                          ).tr(),
                          onTap: () {
                            if (popOnSelect) Navigator.of(context).pop();
                            goToBlacklistedTagPage(context);
                          },
                        ),
                      _SideMenuTile(
                        icon: const Icon(Icons.download),
                        title: const Text('download.bulk_download').tr(),
                        onTap: () {
                          if (popOnSelect) Navigator.of(context).pop();
                          goToBulkDownloadPage(context, null);
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
                  )
                : const SizedBox.shrink();
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
