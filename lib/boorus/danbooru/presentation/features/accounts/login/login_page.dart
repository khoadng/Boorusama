import 'package:boorusama/generated/i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/style.dart';

import 'widgets/login_box_widget.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          shadowColor: Colors.transparent,
        ),
        resizeToAvoidBottomInset: false,
        body: Column(
          children: <Widget>[
            Text(
              I18n.of(context).loginFormGreeting,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white70,
                fontSize: FontSize.xLarge.size,
              ),
            ),
            Center(
              child: LoginBox(),
            )
          ],
        ),
      ),
    );
  }
}
