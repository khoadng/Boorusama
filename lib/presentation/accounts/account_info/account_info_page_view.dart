import 'package:boorusama/application/authentication/bloc/authentication_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:widget_view/widget_view.dart';

import 'account_info_page.dart';

class AccountInfoPageView
    extends StatefulWidgetView<AccountInfoPage, AccountInfoPageState> {
  AccountInfoPageView(AccountInfoPageState controller, {Key key})
      : super(controller, key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Profile"),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.logout),
                onPressed: () => controller.removeAccountRequest()),
          ],
        ),
        body: Column(
          children: <Widget>[
            buildAccountList(),
            Align(
              alignment: Alignment.bottomLeft,
              child: FlatButton(
                onPressed: () {
                  // open full page
                },
                textColor: Colors.blue,
                child: Text('Favorites'),
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

  Widget buildAccountList() {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          controller.removeAccount(state.account);
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        if (state is Unauthenticated) {
          return Center();
        } else {
          return Text(controller.accounts.first.username);
        }
      },
    );
  }
}
