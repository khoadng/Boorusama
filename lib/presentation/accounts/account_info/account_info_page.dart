import 'package:boorusama/application/accounts/remove_account/bloc/remove_account_bloc.dart';
import 'package:boorusama/domain/accounts/account.dart';
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
  RemoveAccountBloc _removeAccountBloc;

  @override
  void initState() {
    super.initState();
    accounts = widget.accounts;
    _removeAccountBloc = BlocProvider.of<RemoveAccountBloc>(context);
  }

  void removeAccount(Account account) {
    setState(() {
      accounts.removeWhere((element) => element.username == account.username);
    });
  }

  void removeAccountRequest() {
    _removeAccountBloc.add(RemoveAccountRequested(account: accounts[0]));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => AccountInfoPageView(this);
}
