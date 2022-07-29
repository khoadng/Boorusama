// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/account/account.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/core.dart';

double _screenSizeToWidthWeight(ScreenSize size) {
  if (size == ScreenSize.small) return 0.7;
  if (size == ScreenSize.medium) return 0.3;
  if (size == ScreenSize.large) return 0.2;
  return 0.15;
}

class SideBarMenu extends StatelessWidget {
  const SideBarMenu({
    Key? key,
    this.width,
    this.popOnSelect = false,
    this.initialContentBuilder,
  }) : super(key: key);

  final double? width;
  final bool popOnSelect;
  final List<Widget>? Function(BuildContext context)? initialContentBuilder;

  @override
  Widget build(BuildContext context) {
    final size = Screen.of(context).size;
    return Container(
      color: Theme.of(context).backgroundColor,
      constraints: BoxConstraints.expand(
          width: width ??
              MediaQuery.of(context).size.width *
                  _screenSizeToWidthWeight(size)),
      child: SingleChildScrollView(
        child: BlocBuilder<AccountCubit, AsyncLoadState<Account>>(
          builder: (context, state) {
            if (state.status == LoadStatus.success) {
              return Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Column(
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
                      ListTile(
                        leading: const Icon(Icons.login_outlined),
                        title: Text('sideMenu.login'.tr()),
                        onTap: () {
                          if (popOnSelect) Navigator.of(context).pop();
                          AppRouter.router.navigateTo(context, '/login');
                        },
                      )
                    else
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text('sideMenu.profile'.tr()),
                        onTap: () {
                          if (popOnSelect) Navigator.of(context).pop();
                          AppRouter.router
                              .navigateTo(context, '/users/profile');
                        },
                      ),
                    if (state.data! != Account.empty)
                      ListTile(
                        leading: const Icon(Icons.favorite_outline),
                        title: Text('profile.favorites'.tr()),
                        onTap: () {
                          if (popOnSelect) Navigator.of(context).pop();
                          AppRouter.router.navigateTo(context, '/favorites',
                              routeSettings: RouteSettings(
                                  arguments: [state.data!.username]));
                        },
                      ),
                    if (state.data! != Account.empty)
                      ListTile(
                        leading: const Icon(Icons.hide_source),
                        title: const Text('blacklisted_tags.blacklisted_tags')
                            .tr(),
                        onTap: () {
                          if (popOnSelect) Navigator.of(context).pop();
                          AppRouter.router
                              .navigateTo(context, '/users/blacklisted_tags');
                        },
                      ),
                    ListTile(
                      leading: const Icon(Icons.settings_outlined),
                      title: Text('sideMenu.settings'.tr()),
                      onTap: () {
                        if (popOnSelect) Navigator.of(context).pop();
                        AppRouter.router.navigateTo(context, '/settings');
                      },
                    ),
                  ],
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}
