// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:hooks_riverpod/all.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_state_notifier.dart';
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
        body: Column(
          children: <Widget>[
            Consumer(
              builder: (context, watch, child) =>
                  watch(accountStateProvider).maybeWhen(
                loggedOut: () => Center(),
                orElse: () => Text(widget.accountId.toString()),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: FlatButton(
                onPressed: () {
                  // open full page
                },
                textColor: Colors.blue,
                child: Text(I18n.of(context).profileFavorites),
              ),
            ),
            // BlocListener<PostFavoritesBloc, PostFavoritesState>(
            //   listener: (BuildContext context, state) {
            //     state.maybeWhen(
            //       orElse: () {},
            //       loaded: (posts) => controller.assignFavedPosts(posts),
            //     );
            //   },
            //   child: SizedBox(
            //     width: MediaQuery.of(context).size.width,
            //     height: 200,
            //     child: ListView.builder(
            //       scrollDirection: Axis.horizontal,
            //       itemCount: controller.favedPosts.length,
            //       itemBuilder: (context, index) {
            //         return Container(
            //           margin: EdgeInsets.symmetric(horizontal: 5.0),
            //           child: CachedNetworkImage(
            //               fit: BoxFit.contain,
            //               imageUrl: controller.favedPosts[index].previewImageUri
            //                   .toString()),
            //         );
            //       },
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
