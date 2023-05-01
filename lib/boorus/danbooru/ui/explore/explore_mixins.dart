// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/ui/post_grid_controller.dart';

mixin PostExplorerMixin<T extends StatefulWidget, E> on State<T> {
  PostGridController<E> get controller;

  var posts = <E>[];

  @override
  void initState() {
    super.initState();
    controller.addListener(_onControllerChange);
    controller.refresh();
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(_onControllerChange);
    controller.dispose();
  }

  void _onControllerChange() {
    if (controller.items.isNotEmpty) {
      setState(() {
        posts = controller.items;
      });
    }
  }
}
