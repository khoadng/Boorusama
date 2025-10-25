// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/posts/listing/providers.dart';
import '../../post/types.dart';
import '../../post/widgets.dart';

class DanbooruPostListingContextMenu extends ConsumerWidget {
  const DanbooruPostListingContextMenu({
    super.key,
    required this.index,
    required this.controller,
    required this.child,
  });

  final int index;
  final PostGridController<DanbooruPost> controller;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder(
      valueListenable: controller.itemsNotifier,
      builder: (context, posts, _) {
        final post = posts[index];
        return DanbooruPostContextMenu(
          post: post,
          index: index,
          child: child,
        );
      },
    );
  }
}
