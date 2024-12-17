// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

extension TextEditingControllerX on TextEditingController {
  Stream<String> textAsStream() {
    late StreamController<String> controller;
    void addListener() => controller.add(value.text);
    void onListen() => this.addListener(addListener);
    void onCancel() {
      removeListener(addListener);
      controller.close();
    }

    controller =
        StreamController<String>(onListen: onListen, onCancel: onCancel);

    return controller.stream;
  }
}
