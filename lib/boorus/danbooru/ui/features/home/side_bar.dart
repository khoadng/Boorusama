// Flutter imports:
import 'package:boorusama/boorus/booru_factory.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/user_booru_repository.dart';
import 'package:boorusama/core/application/booru_user_identity_provider.dart';
import 'package:boorusama/core/application/manage_booru_user_bloc.dart';
import 'package:boorusama/core/ui/manage_booru_user_page.dart';
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
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

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
                        _SideMenuTile(
                          icon: const Icon(Icons.collections),
                          title: const Text('Favorite groups'),
                          onTap: () {
                            if (popOnSelect) Navigator.of(context).pop();
                            goToFavoriteGroupPage(context);
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
                        icon: const Icon(Icons.account_box_sharp),
                        title: const Text('Manage Accounts'),
                        onTap: () {
                          if (popOnSelect) Navigator.of(context).pop();
                          showMaterialModalBottomSheet(
                            context: context,
                            builder: (context) => MultiBlocProvider(
                              providers: [
                                BlocProvider(
                                  create: (context) => ManageBooruUserBloc(
                                    userBooruRepository:
                                        context.read<UserBooruRepository>(),
                                    booruFactory: context.read<BooruFactory>(),
                                    booruUserIdentityProvider: context
                                        .read<BooruUserIdentityProvider>(),
                                  )..add(const ManageBooruUserFetched()),
                                ),
                              ],
                              child: const ManageBooruUserPage(),
                            ),
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
