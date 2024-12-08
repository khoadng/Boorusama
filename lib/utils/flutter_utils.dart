// Flutter imports:
import 'package:flutter/material.dart';

class ShrinkVisualDensity extends VisualDensity {
  const ShrinkVisualDensity() : super(horizontal: -4, vertical: -4);
}

extension TextEditingControllerX on TextEditingController {
  void setTextAndCollapseSelection(String text) {
    this
      ..text = text
      ..selection = TextSelection.collapsed(offset: text.length);
  }
}
