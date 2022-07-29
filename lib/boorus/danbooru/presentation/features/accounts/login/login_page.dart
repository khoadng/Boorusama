// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_html/style.dart';

// Project imports:
import 'widgets/login_box_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'login.form.greeting'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.white70,
                  fontSize: FontSize.xLarge.size,
                ),
              ),
              const Center(
                child: LoginBox(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
