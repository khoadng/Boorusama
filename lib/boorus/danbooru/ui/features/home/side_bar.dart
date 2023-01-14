// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/account/account.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/core.dart';
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
                            AppRouter.router.navigateTo(
                              context,
                              '/login',
                              transition:
                                  Screen.of(context).size == ScreenSize.small
                                      ? TransitionType.inFromRight
                                      : null,
                            );
                          },
                        )
                      else
                        _SideMenuTile(
                          icon: const Icon(Icons.person_outline),
                          title: Text('sideMenu.profile'.tr()),
                          onTap: () {
                            if (popOnSelect) Navigator.of(context).pop();
                            AppRouter.router.navigateTo(
                              context,
                              '/users/profile',
                              transition:
                                  Screen.of(context).size == ScreenSize.small
                                      ? TransitionType.inFromRight
                                      : null,
                            );
                          },
                        ),
                      if (state.data! != Account.empty)
                        _SideMenuTile(
                          icon: const Icon(Icons.favorite_outline),
                          title: Text('profile.favorites'.tr()),
                          onTap: () {
                            if (popOnSelect) Navigator.of(context).pop();
                            AppRouter.router.navigateTo(
                              context,
                              '/favorites',
                              routeSettings: RouteSettings(
                                arguments: [state.data!.username],
                              ),
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
                            AppRouter.router.navigateTo(
                              context,
                              '/saved_search',
                              routeSettings: RouteSettings(
                                arguments: [state.data!.username],
                              ),
                              transition:
                                  Screen.of(context).size == ScreenSize.small
                                      ? TransitionType.inFromRight
                                      : null,
                            );
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
                            AppRouter.router.navigateTo(
                              context,
                              '/users/blacklisted_tags',
                              transition:
                                  Screen.of(context).size == ScreenSize.small
                                      ? TransitionType.inFromRight
                                      : null,
                            );
                          },
                        ),
                      _SideMenuTile(
                        icon: const Icon(Icons.download),
                        title: const Text('download.bulk_download').tr(),
                        onTap: () {
                          if (popOnSelect) Navigator.of(context).pop();
                          AppRouter.router.navigateTo(
                            context,
                            '/bulk_download',
                            routeSettings: const RouteSettings(
                              arguments: [],
                            ),
                            transition:
                                Screen.of(context).size == ScreenSize.small
                                    ? TransitionType.inFromRight
                                    : null,
                          );
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
