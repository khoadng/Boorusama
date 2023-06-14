// Flutter imports:
import 'package:flutter/material.dart';

mixin EditableMixin<T extends StatefulWidget> on State<T> {
  var _edit = false;

  void startEditMode() {
    setState(() {
      _edit = true;
    });
  }

  void endEditMode() {
    setState(() {
      _edit = false;
    });
  }

  bool get edit => _edit;
}
