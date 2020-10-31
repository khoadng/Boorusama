import 'package:boorusama/application/accounts/add_account/bloc/add_account_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginBox extends StatefulWidget {
  const LoginBox({Key key}) : super(key: key);

  @override
  _LoginBoxState createState() => _LoginBoxState();
}

class _LoginBoxState extends State<LoginBox> {
  TextEditingController _usernameTextController;
  TextEditingController _passwordTextController;
  AddAccountBloc _addAccountBloc;

  @override
  void initState() {
    super.initState();
    _addAccountBloc = BlocProvider.of<AddAccountBloc>(context);
    _usernameTextController = TextEditingController();
    _passwordTextController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameTextController.dispose();
    _passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(100.0),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: _usernameTextController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'User Name',
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: _passwordTextController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
          ),
          BlocConsumer<AddAccountBloc, AddAccountState>(
            listener: (context, state) {
              if (state is AddAccountDone) {
                Navigator.pop(context, state.account);
              }
            },
            builder: (context, state) {
              if (state is AddAccountProcessing) {
                return CircularProgressIndicator();
              } else {
                return Container(
                    height: 50,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: RaisedButton(
                      textColor: Colors.white70,
                      color: Colors.blue,
                      child: Text('Login'),
                      onPressed: () => _addAccountBloc.add(AddAccountRequested(
                          username: _usernameTextController.text,
                          password: _passwordTextController.text)),
                    ));
              }
            },
          ),
        ],
      ),
    );
  }
}
