// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import 'package:boorusama/core/widgets/widgets.dart';
import '../post.dart';
import '../post_repository.dart';
import 'post_grid.dart';
import 'post_scope.dart';

class SinglePagePostListScaffold<T extends Post>
    extends ConsumerStatefulWidget {
  const SinglePagePostListScaffold({
    super.key,
    required this.posts,
    this.sliverHeaders,
  });

  final List<T> posts;
  final List<Widget>? sliverHeaders;

  @override
  ConsumerState<SinglePagePostListScaffold<T>> createState() =>
      _SinglePagePostListScaffoldState<T>();
}

class _SinglePagePostListScaffoldState<T extends Post>
    extends ConsumerState<SinglePagePostListScaffold<T>> {
  @override
  Widget build(BuildContext context) {
    return CustomContextMenuOverlay(
      child: PostScope(
        fetcher: (page) => TaskEither.Do(
          ($) async => page == 1 ? widget.posts.toResult() : <T>[].toResult(),
        ),
        builder: (context, controller) => PostGrid(
          controller: controller,
          sliverHeaders: [
            if (widget.sliverHeaders != null) ...widget.sliverHeaders!,
          ],
        ),
      ),
    );
  }
}
