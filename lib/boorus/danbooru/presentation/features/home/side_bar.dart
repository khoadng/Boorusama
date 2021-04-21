// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/generated/i18n.dart';

class SideBarMenu extends HookWidget {
  SideBarMenu();

  @override
  Widget build(BuildContext context) {
    final drawerChildren = <Widget>[];
    final account = useProvider(currentAccountProvider);

    if (account == null) {
      drawerChildren.add(ListTile(
        leading: Icon(Icons.login),
        title: Text(I18n.of(context).sideMenuLogin),
        onTap: () {
          Navigator.of(context).pop();
          AppRouter.router.navigateTo(context, "/login");
        },
      ));
    } else {
      drawerChildren.add(ListTile(
        leading: Icon(Icons.person),
        title: Text(I18n.of(context).sideMenuProfile),
        onTap: () {
          Navigator.of(context).pop();
          AppRouter.router.navigateTo(context, "/users/profile");
        },
      ));
    }

    drawerChildren.add(Divider());

    drawerChildren.add(ListTile(
      leading: Icon(Icons.settings),
      title: Text(I18n.of(context).sideMenuSettings),
      onTap: () {
        Navigator.of(context).pop();
        AppRouter.router.navigateTo(context, "/settings");
      },
    ));

    //TODO: unfinished feature
    // drawerChildren.add(ListTile(
    //   leading: Icon(Icons.download_rounded),
    //   title: Text("Downloads"),
    //   onTap: () {
    //     Navigator.of(context).pop();
    //     AppRouter.router.navigateTo(context, "/downloads");
    //   },
    // ));

    return Drawer(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: drawerChildren),
          ),
        ),
      ),
    );
  }
}
