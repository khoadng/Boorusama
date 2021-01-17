import 'package:flutter/material.dart';

import 'widgets/login_box_widget.dart';

class AddAccountPage extends StatefulWidget {
  AddAccountPage({Key key}) : super(key: key);

  @override
  _AddAccountPageState createState() => _AddAccountPageState();
}

class _AddAccountPageState extends State<AddAccountPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(child: LoginBox()),
      ),
    );
  }
}
