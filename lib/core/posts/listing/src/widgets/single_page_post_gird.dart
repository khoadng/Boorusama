// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../post/types.dart';
import 'post_grid.dart';
import 'post_scope.dart';

class SinglePagePostListScaffold<T extends Post>
    extends ConsumerStatefulWidget {
  const SinglePagePostListScaffold({
    required this.posts,
    super.key,
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
    return PostScope(
      fetcher: (page) => TaskEither.Do(
        ($) async => page == 1 ? widget.posts.toResult() : <T>[].toResult(),
      ),
      builder: (context, controller) => PostGrid(
        controller: controller,
        sliverHeaders: [
          if (widget.sliverHeaders != null) ...widget.sliverHeaders!,
        ],
      ),
    );
  }
}
