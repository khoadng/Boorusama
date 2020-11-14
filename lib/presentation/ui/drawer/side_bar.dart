import 'package:boorusama/domain/accounts/account.dart';
import 'package:boorusama/presentation/accounts/account_info/account_info_page.dart';
import 'package:boorusama/presentation/accounts/add_account/add_account_page.dart';
import 'package:boorusama/presentation/settings/settings_page.dart';
import 'package:boorusama/presentation/ui/drawer/drawer_item.dart';
import 'package:flutter/material.dart';

class SideBarMenu extends StatelessWidget {
  final Account account;

  SideBarMenu({this.account});

  @override
  Widget build(BuildContext context) {
    final drawerChildren = <Widget>[];

    if (account == null) {
      drawerChildren.add(DrawerItem(
        leading: Icon(Icons.login),
        text: "Login",
        onPressed: () {
          Navigator.of(context).pop();
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => AddAccountPage()));
        },
      ));
    } else {
      drawerChildren.add(DrawerItem(
        leading: Icon(Icons.person),
        text: "Profile",
        onPressed: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AccountInfoPage(
                    accounts: [account],
                  )));
        },
      ));
    }

    drawerChildren.add(Divider());

    drawerChildren.add(DrawerItem(
      leading: Icon(Icons.settings),
      text: "Settings",
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => SettingsPage()));
      },
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

class _DrawerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(50, 0);
    path.quadraticBezierTo(0, size.height / 2, 50, size.height);
    path.lineTo(0, size.height / 2);
    path.lineTo(50, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
