import 'package:boorusama/boorus/danbooru/domain/accounts/account.dart';
import 'package:boorusama/generated/i18n.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/accounts/add_account/add_account_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/settings/settings_page.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:flutter/material.dart';

class SideBarMenu extends StatelessWidget {
  final Account account;

  SideBarMenu({this.account});

  @override
  Widget build(BuildContext context) {
    final drawerChildren = <Widget>[];

    if (account == null) {
      drawerChildren.add(ListTile(
        leading: Icon(Icons.login),
        title: Text(I18n.of(context).sideMenuLogin),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => AddAccountPage()));
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
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => SettingsPage()));
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
