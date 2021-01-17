import 'package:boorusama/application/authentication/bloc/authentication_bloc.dart';
import 'package:boorusama/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class LoginBox extends HookWidget {
  const LoginBox({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _formKey = useState(GlobalKey<FormState>());
    final _isValidUsernameAndPassword = useState(true);
    final usernameTextController = useTextEditingController();
    final passwordTextController = useTextEditingController();

    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is Authenticated) {
          _isValidUsernameAndPassword.value = true;
          Navigator.pop(context, state.account);
        } else if (state is AuthenticationError) {
          _isValidUsernameAndPassword.value = false;
          _formKey.value.currentState.validate();
        } else if (state is Unauthenticated) {}
      },
      builder: (context, state) {
        return Form(
          // margin: EdgeInsets.symmetric(horizontal: 20.0),
          autovalidateMode: AutovalidateMode.disabled,
          key: _formKey.value,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return I18n.of(context).loginErrorsMissingUsername;
                    }

                    if (!_isValidUsernameAndPassword.value) {
                      return I18n.of(context)
                          .loginErrorsInvalidUsernameOrPassword;
                    }
                    return null;
                  },
                  controller: usernameTextController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: I18n.of(context).loginFormUsername,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return I18n.of(context).loginErrorsMissingPassword;
                    }
                    if (!_isValidUsernameAndPassword.value) {
                      return I18n.of(context)
                          .loginErrorsInvalidUsernameOrPassword;
                    }
                    return null;
                  },
                  controller: passwordTextController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: I18n.of(context).loginFormPassword,
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
                        child: Text(I18n.of(context).loginFormLogin),
                        onPressed: () {
                          if (_formKey.value.currentState.validate()) {
                            context.read<AuthenticationBloc>().add(
                                  UserLoggedIn(
                                      username: usernameTextController.text,
                                      password: passwordTextController.text),
                                );
                          } else {
                            _isValidUsernameAndPassword.value = true;
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
