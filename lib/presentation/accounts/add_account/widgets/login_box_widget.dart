import 'package:boorusama/application/authentication/bloc/authentication_bloc.dart';
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
  final _formKey = GlobalKey<FormState>();
  bool _isValidUsernameAndPassword = true;

  @override
  void initState() {
    super.initState();
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
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is Authenticated) {
          _isValidUsernameAndPassword = true;
          Navigator.pop(context, state.account);
        } else if (state is AuthenticationError) {
          _isValidUsernameAndPassword = false;
          _formKey.currentState.validate();
        } else if (state is Unauthenticated) {}
      },
      builder: (context, state) {
        return Form(
          // margin: EdgeInsets.symmetric(horizontal: 20.0),
          autovalidateMode: AutovalidateMode.disabled,
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Please enter your username";
                    }

                    if (!_isValidUsernameAndPassword) {
                      return "Invalid username or password";
                    }
                    return null;
                  },
                  controller: _usernameTextController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Name',
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Please enter your password";
                    }
                    if (!_isValidUsernameAndPassword) {
                      return "Invalid username or password";
                    }
                    return null;
                  },
                  controller: _passwordTextController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
              ),
              BlocBuilder<AuthenticationBloc, AuthenticationState>(
                builder: (context, state) {
                  if (state is Authenticating) {
                    return CircularProgressIndicator();
                  } else {
                    return Container(
                      height: 50,
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: RaisedButton(
                        textColor: Colors.white70,
                        color: Colors.blue,
                        child: Text('Login'),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            context.read<AuthenticationBloc>().add(
                                  UserLoggedIn(
                                      username: _usernameTextController.text,
                                      password: _passwordTextController.text),
                                );
                          } else {
                            _isValidUsernameAndPassword = true;
                          }
                        },
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
