import 'package:boorusama/presentation/accounts/add_account/widgets/login_box_widget.dart';
import 'package:flutter/material.dart';

class AddAccountPage extends StatefulWidget {
  AddAccountPage({Key key}) : super(key: key);

  @override
  _AddAccountPageState createState() => _AddAccountPageState();
}

class _AddAccountPageState extends State<AddAccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(child: LoginBox()),
    );
  }
}
