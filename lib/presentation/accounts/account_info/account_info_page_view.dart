import 'package:boorusama/application/authentication/bloc/authentication_bloc.dart';
import 'package:boorusama/application/posts/post_favorites/bloc/post_favorites_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
    return Scaffold(
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
          BlocListener<PostFavoritesBloc, PostFavoritesState>(
            listener: (BuildContext context, state) {
              if (state is PostFavoritesLoaded) {
                controller.assignFavedPosts(state.posts);
              }
            },
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.favedPosts.length,
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                      fit: BoxFit.contain,
                      imageUrl: controller.favedPosts[index].previewImageUri
                          .toString());
                },
              ),
            ),
          ),
          RaisedButton.icon(
            icon: Icon(Icons.logout),
            onPressed: () => controller.removeAccountRequest(),
            label: Text("Log out"),
          ),
        ],
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
