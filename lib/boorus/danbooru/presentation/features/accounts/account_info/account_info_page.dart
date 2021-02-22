// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:hooks_riverpod/all.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/favorites/favorites_page.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/generated/i18n.dart';

class AccountInfoPage extends StatefulWidget {
  const AccountInfoPage({
    Key key,
    this.accountId,
  }) : super(key: key);

  final int accountId;

  @override
  _AccountInfoPageState createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(I18n.of(context).profileProfile),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  context.read(authenticationStateNotifierProvider).logOut();
                  AppRouter.router.navigateTo(context, "/",
                      clearStack: true, replace: true);
                }),
          ],
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
                child: Text(
              I18n.of(context).profileFavorites,
              style: Theme.of(context).textTheme.headline6,
            )),
            SliverFillRemaining(child: FavoritesPage()),
          ],
        ),
      ),
    );
  }
}
