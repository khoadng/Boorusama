import 'package:boorusama/application/accounts/get_all_accounts/bloc/get_all_accounts_bloc.dart';
import 'package:boorusama/application/accounts/remove_account/bloc/remove_account_bloc.dart';
import 'package:boorusama/presentation/accounts/account_list/account_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:widget_view/widget_view.dart';

class AccountListPageView
    extends StatefulWidgetView<AccountListPage, AccountListPageState> {
  AccountListPageView(AccountListPageState controller, {Key key})
      : super(controller, key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(child: buildAccountList()),
          IconButton(
              icon: Icon(Icons.add), onPressed: () => controller.addAccount()),
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
                controller.removeAccount(state.account);
              }
            },
          )
        ],
        child: BlocBuilder<GetAllAccountsBloc, GetAllAccountsState>(
            builder: (context, state) {
          if (state is GetAllAccountsSuccess) {
            if (state.accounts != null && state.accounts.isNotEmpty) {
              controller.accounts = state.accounts;
              return _AccountList(controller: controller);
            } else {
              return _NoAccountDisplay();
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        }));
  }
}

class _NoAccountDisplay extends StatelessWidget {
  const _NoAccountDisplay({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("No accounts added yet"),
    );
  }
}

class _AccountList extends StatelessWidget {
  const _AccountList({
    Key key,
    @required this.controller,
  }) : super(key: key);

  final AccountListPageState controller;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
          title: Text(controller.accounts[index].username),
          trailing: IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () =>
                controller.removeAccountRequest(controller.accounts[index]),
          )),
      itemCount: controller.accounts.length,
    );
  }
}
