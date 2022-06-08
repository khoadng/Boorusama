// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/account/account_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/account.dart';
import 'package:boorusama/boorus/danbooru/router.dart';

class SideBarMenu extends StatelessWidget {
  const SideBarMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
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
                            AppRouter.router.navigateTo(context, "/login");
                          },
                        )
                      else
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: Text('sideMenu.profile'.tr()),
                          onTap: () {
                            Navigator.of(context).pop();
                            AppRouter.router
                                .navigateTo(context, "/users/profile");
                          },
                        ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.settings),
                        title: Text('sideMenu.settings'.tr()),
                        onTap: () {
                          Navigator.of(context).pop();
                          AppRouter.router.navigateTo(context, "/settings");
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
    );
  }
}
