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
    this.width,
    this.popOnSelect = false,
    this.initialContentBuilder,
  }) : super(key: key);

  final double? width;
  final bool popOnSelect;
  final List<Widget>? Function(BuildContext context)? initialContentBuilder;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Theme.of(context).backgroundColor,
        constraints: BoxConstraints.expand(width: width ?? 250),
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
                          if (initialContentBuilder != null) ...[
                            ...initialContentBuilder!(context)!,
                            const _Divider(),
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
                                AppRouter.router.navigateTo(
                                    context, '/favorites',
                                    routeSettings: RouteSettings(
                                        arguments: [state.data!.username]));
                              },
                            ),
                          if (state.data! != Account.empty)
                            ListTile(
                              leading: const Icon(Icons.hide_source),
                              title: const Text(
                                      'blacklisted_tags.blacklisted_tags')
                                  .tr(),
                              onTap: () {
                                if (popOnSelect) Navigator.of(context).pop();
                                AppRouter.router.navigateTo(
                                    context, '/users/blacklisted_tags');
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
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),
            ),
            const _Divider(),
            const _Footer(),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 4,
      indent: 8,
      endIndent: 8,
      thickness: 2,
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ButtonBar(
        alignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => launchExternalUrl(
              Uri.parse(context.read<AppInfoProvider>().appInfo.githubUrl),
              mode: LaunchMode.externalApplication,
            ),
            icon: const FaIcon(FontAwesomeIcons.githubSquare),
          ),
          IconButton(
            onPressed: () => launchExternalUrl(
              Uri.parse(context.read<AppInfoProvider>().appInfo.discordUrl),
              mode: LaunchMode.externalApplication,
            ),
            icon: const FaIcon(FontAwesomeIcons.discord),
          ),
        ],
      ),
    );
  }
}
