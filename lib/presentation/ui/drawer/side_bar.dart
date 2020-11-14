import 'package:boorusama/domain/accounts/account.dart';
import 'package:boorusama/presentation/accounts/account_info/account_info_page.dart';
import 'package:boorusama/presentation/accounts/add_account/add_account_page.dart';
import 'package:boorusama/presentation/settings/settings_page.dart';
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
        title: Text("Login"),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => AddAccountPage()));
        },
      ));
    } else {
      drawerChildren.add(ListTile(
        leading: Icon(Icons.person),
        title: Text("Profile"),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AccountInfoPage(
                    accounts: [account],
                  )));
        },
      ));
    }

    drawerChildren.add(Divider());

    drawerChildren.add(ListTile(
      leading: Icon(Icons.settings),
      title: Text("Settings"),
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
