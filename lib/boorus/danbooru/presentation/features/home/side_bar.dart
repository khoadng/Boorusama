import 'package:boorusama/boorus/danbooru/application/authentication/authentication_state_notifier.dart';
import 'package:boorusama/generated/i18n.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';

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
          AppRouter.router.navigateTo(context, "/users/${account.id}");
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

    drawerChildren.add(AboutListTile(
      icon: Icon(Icons.info),
      applicationIcon: FlutterLogo(),
      applicationVersion: "Alpha T.B.D",
      applicationLegalese: "\u{a9} 2020 Nguyen Duc Khoa",
      applicationName: "Boorusama",
      aboutBoxChildren: <Widget>[
        SizedBox(height: 24),
        Text("Blah blah T.B.D"),
      ],
    ));

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
