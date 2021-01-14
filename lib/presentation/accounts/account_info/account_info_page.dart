import 'package:boorusama/application/authentication/bloc/authentication_bloc.dart';
import 'package:boorusama/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          title: Text("Profile"),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  BlocProvider.of<AuthenticationBloc>(context)
                      .add(UserLoggedOut(accountId: widget.accountId));
                  AppRouter.router.navigateTo(context, "/",
                      clearStack: true, replace: true);
                }),
          ],
        ),
        body: Column(
          children: <Widget>[
            BlocBuilder<AuthenticationBloc, AuthenticationState>(
              builder: (context, state) {
                if (state is Unauthenticated) {
                  return Center();
                } else {
                  return Text(widget.accountId.toString());
                }
              },
            ),
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
}
