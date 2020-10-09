import 'package:boorusama/application/accounts/get_all_accounts/bloc/get_all_accounts_bloc.dart';
import 'package:boorusama/application/accounts/remove_account/bloc/remove_account_bloc.dart';
import 'package:boorusama/domain/accounts/account.dart';
import 'package:boorusama/presentation/accounts/account_list/account_list_page_view.dart';
import 'package:boorusama/presentation/accounts/add_account/add_account_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountListPage extends StatefulWidget {
  const AccountListPage({
    Key key,
  }) : super(key: key);

  @override
  AccountListPageState createState() => AccountListPageState();
}

class AccountListPageState extends State<AccountListPage> {
  List<Account> accounts;
  GetAllAccountsBloc _getAllAccountsBloc;
  RemoveAccountBloc _removeAccountBloc;

  @override
  void initState() {
    super.initState();
    accounts = List<Account>();
    _getAllAccountsBloc = BlocProvider.of<GetAllAccountsBloc>(context);
    _removeAccountBloc = BlocProvider.of<RemoveAccountBloc>(context);

    _getAllAccountsBloc.add(GetAllAccountsRequested());
  }

  void addAccount() async {
    final result = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => AddAccountPage()));
    setState(() {
      accounts.add(result);
    });
  }

  void removeAccount(Account account) {
    setState(() {
      accounts.removeWhere((element) => element.username == account.username);
    });
  }

  void removeAccountRequest(Account account) =>
      _removeAccountBloc.add(RemoveAccountRequested(account: account));

  @override
  Widget build(BuildContext context) => AccountListPageView(this);
}
