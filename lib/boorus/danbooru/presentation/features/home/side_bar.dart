// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/account/account.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/main.dart';

class SideBarMenu extends StatelessWidget {
  const SideBarMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: BlocBuilder<AccountCubit, AsyncLoadState<Account>>(
                  builder: (context, state) {
                    if (state.status == LoadStatus.success) {
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (state.data! == Account.empty)
                              ListTile(
                                leading: const Icon(Icons.login),
                                title: Text('sideMenu.login'.tr()),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  AppRouter.router
                                      .navigateTo(context, '/login');
                                },
                              )
                            else
                              ListTile(
                                leading: const Icon(Icons.person),
                                title: Text('sideMenu.profile'.tr()),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  AppRouter.router
                                      .navigateTo(context, '/users/profile');
                                },
                              ),
                            if (state.data! != Account.empty)
                              ListTile(
                                leading:
                                    const FaIcon(FontAwesomeIcons.solidHeart),
                                title: Text('profile.favorites'.tr()),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  AppRouter.router.navigateTo(
                                      context, '/favorites',
                                      routeSettings: RouteSettings(
                                          arguments: [state.data!.username]));
                                },
                              ),
                            if (state.data! != Account.empty)
                              ListTile(
                                leading: const FaIcon(FontAwesomeIcons.ban),
                                title: const Text(
                                        'blacklisted_tags.blacklisted_tags')
                                    .tr(),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  AppRouter.router.navigateTo(
                                      context, '/users/blacklisted_tags');
                                },
                              ),
                            ListTile(
                              leading: const Icon(Icons.settings),
                              title: Text('sideMenu.settings'.tr()),
                              onTap: () {
                                Navigator.of(context).pop();
                                AppRouter.router
                                    .navigateTo(context, '/settings');
                              },
                            )
                          ]);
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),
            ),
            const Divider(
              height: 4,
              indent: 8,
              endIndent: 8,
              thickness: 2,
            ),
            SizedBox(
              height: 50,
              child: ButtonBar(
                alignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => launchExternalUrl(
                      Uri.parse(
                          context.read<AppInfoProvider>().appInfo.githubUrl),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const FaIcon(FontAwesomeIcons.githubSquare),
                  ),
                  IconButton(
                    onPressed: () => launchExternalUrl(
                      Uri.parse(
                          context.read<AppInfoProvider>().appInfo.discordUrl),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const FaIcon(FontAwesomeIcons.discord),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
