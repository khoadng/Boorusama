// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'widgets/login_box_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

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
              WarningContainer(
                contentBuilder: (context) => const Text('login.notice').tr(),
              ),
              const Center(
                child: LoginBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
