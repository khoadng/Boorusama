// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/scaffolds/infinite_post_list_scaffold.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/gelbooru/widgets/gelbooru_post_context_menu.dart';
import 'package:boorusama/foundation/error.dart';

class GelbooruInfinitePostList extends ConsumerWidget {
  const GelbooruInfinitePostList({
    super.key,
    this.sliverHeaderBuilder,
    required this.controller,
    this.errors,
  });

  final List<Widget> Function(BuildContext context)? sliverHeaderBuilder;
  final PostGridController<Post> controller;
  final BooruError? errors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InfinitePostListScaffold(
      errors: errors,
      controller: controller,
      sliverHeaderBuilder: sliverHeaderBuilder,
      contextMenuBuilder: (post, next) => GelbooruPostContextMenu(
        hasAccount: false,
        onMultiSelect: () => next(),
        post: post,
      ),
    );
  }
}
