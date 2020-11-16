import 'package:boorusama/application/authentication/bloc/authentication_bloc.dart';
import 'package:boorusama/application/posts/post_favorites/bloc/post_favorites_bloc.dart';
import 'package:boorusama/domain/accounts/account.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'account_info_page_view.dart';

class AccountInfoPage extends StatefulWidget {
  const AccountInfoPage({
    Key key,
    this.accounts,
  }) : super(key: key);

  final List<Account> accounts;

  @override
  AccountInfoPageState createState() => AccountInfoPageState();
}

class AccountInfoPageState extends State<AccountInfoPage> {
  List<Account> accounts;
  List<Post> favedPosts;

  @override
  void initState() {
    super.initState();
    accounts = widget.accounts;
    favedPosts = List<Post>();

    //TODO: warning dirty code to get current account

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostFavoritesBloc>().add(
            PostFavoritesEvent.fetched(
              username: accounts.first.username,
              page: 1,
            ),
          );
    });
  }

  void removeAccount(Account account) {
    setState(() {
      accounts.removeWhere((element) => element.username == account.username);
    });
  }

  void removeAccountRequest() {
    BlocProvider.of<AuthenticationBloc>(context)
        .add(UserLoggedOut(account: accounts[0]));
  }

  void assignFavedPosts(List<Post> posts) {
    setState(() {
      favedPosts = posts;
    });
  }

  @override
  Widget build(BuildContext context) => AccountInfoPageView(this);
}
