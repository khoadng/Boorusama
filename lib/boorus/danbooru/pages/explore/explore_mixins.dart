// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';

mixin PostExplorerMixin<T extends StatefulWidget, E extends Post> on State<T> {
  PostGridController<E> get controller;

  Set<String> get blacklistedTags;

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
        posts = filterTags(controller.items, blacklistedTags);
      });
    }
  }
}
