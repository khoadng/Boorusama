// Flutter imports:
import 'package:flutter/material.dart';

mixin MultiSelectableMixin<T extends StatefulWidget, TData> on State<T> {
  final selected = <TData>[];
  var multiSelect = false;

  void addSelected(TData data) {
    setState(() {
      selected.add(data);
    });
  }

  void removeSelected(TData data) {
    setState(() {
      selected.remove(data);
    });
  }

  void clearSelected() {
    setState(() {
      selected.clear();
    });
  }

  void enableMultiSelect() => setState(() {
        multiSelect = true;
      });

  void endMultiSelect() {
    setState(() {
      multiSelect = false;
      selected.clear();
    });
  }
}
