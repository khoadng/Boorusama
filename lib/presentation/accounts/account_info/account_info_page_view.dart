import 'package:boorusama/application/accounts/remove_account/bloc/remove_account_bloc.dart';
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
          Expanded(child: buildAccountList()),
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
        child: _AccountItem(
          controller: controller,
        ));
  }
}

class _AccountItem extends StatelessWidget {
  const _AccountItem({
    Key key,
    @required this.controller,
  }) : super(key: key);

  final AccountInfoPageState controller;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        title: Text(controller.accounts[index].username),
      ),
      itemCount: controller.accounts.length,
    );
  }
}
