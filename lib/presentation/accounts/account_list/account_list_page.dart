import 'package:boorusama/application/accounts/add_account/bloc/add_account_bloc.dart';
import 'package:boorusama/application/accounts/get_all_accounts/bloc/get_all_accounts_bloc.dart';
import 'package:boorusama/application/accounts/remove_account/bloc/remove_account_bloc.dart';
import 'package:boorusama/domain/accounts/account.dart';
import 'package:boorusama/presentation/accounts/add_account/add_account_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountListPage extends StatefulWidget {
  const AccountListPage({
    Key key,
  }) : super(key: key);

  @override
  _AccountListPageState createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  List<Account> _accounts;
  GetAllAccountsBloc _getAllAccountsBloc;
  RemoveAccountBloc _removeAccountBloc;

  @override
  void initState() {
    super.initState();
    _accounts = List<Account>();
    _getAllAccountsBloc = BlocProvider.of<GetAllAccountsBloc>(context);
    _removeAccountBloc = BlocProvider.of<RemoveAccountBloc>(context);

    _getAllAccountsBloc.add(GetAllAccountsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(child: buildAccountList()),
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                final result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AddAccountPage()));
                setState(() {
                  _accounts.add(result);
                });
              }),
        ],
      ),
    );
  }

  Widget buildAccountList() {
    return MultiBlocListener(
        listeners: [
          BlocListener<RemoveAccountBloc, RemoveAccountState>(
            listener: (context, state) {
              if (state is RemoveAccountSuccess) {
                setState(() {
                  _accounts.removeWhere(
                      (element) => element.username == state.account.username);
                });
              }
            },
          )
        ],
        child: BlocBuilder<GetAllAccountsBloc, GetAllAccountsState>(
            builder: (context, state) {
          if (state is GetAllAccountsSuccess) {
            if (state.accounts != null && state.accounts.isNotEmpty) {
              _accounts = state.accounts;
              return ListView.builder(
                itemBuilder: (context, index) => ListTile(
                    title: Text(_accounts[index].username),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline),
                      onPressed: () => _removeAccountBloc.add(
                          RemoveAccountRequested(account: _accounts[index])),
                    )),
                itemCount: _accounts.length,
              );
            } else {
              return Center(
                child: Text("No accounts added yet"),
              );
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        }));
  }
}
