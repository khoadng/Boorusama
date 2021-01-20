import 'package:boorusama/boorus/danbooru/application/authentication/authentication_state_notifier.dart';
import 'package:boorusama/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';

class LoginBox extends HookWidget {
  const LoginBox({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _formKey = useState(GlobalKey<FormState>());
    final _isValidUsernameAndPassword = useState(true);
    final usernameTextController = useTextEditingController();
    final passwordTextController = useTextEditingController();
    final authStatus = useProvider(accountStateProvider);

    return ProviderListener<AccountState>(
      provider: accountStateProvider,
      onChange: (context, status) => status.maybeWhen(
          // ignore: missing_return
          loggedIn: () {
            _isValidUsernameAndPassword.value = true;
            Navigator.of(context).pop();
          },
          // ignore: missing_return
          error: () {
            //TODO: should handle different kind of errors
            _isValidUsernameAndPassword.value = false;
            _formKey.value.currentState.validate();
          },
          // ignore: missing_return
          orElse: () {}),
      child: Form(
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
            authStatus.maybeWhen(
              authenticating: () => CircularProgressIndicator(),
              orElse: () => Container(
                height: 50,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: RaisedButton(
                  textColor: Colors.white70,
                  color: Colors.blue,
                  child: Text(I18n.of(context).loginFormLogin),
                  onPressed: () {
                    if (_formKey.value.currentState.validate()) {
                      context.read(authenticationStateNotifierProvider).logIn(
                          usernameTextController.text,
                          passwordTextController.text);
                      FocusScope.of(context).unfocus();
                    } else {
                      _isValidUsernameAndPassword.value = true;
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
