// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feat/posts/posts.dart';
import 'package:boorusama/boorus/core/feat/settings/settings.dart';
import 'package:boorusama/boorus/core/pages/post_grid_controller.dart';
import 'package:boorusama/foundation/error.dart';

typedef PostFetcher = PostsOrError Function(int page);

mixin PostFetcherMixin<T extends StatefulWidget> on State<T> {
  PostFetcher get fetcher;

  BooruError? errors;

  Future<List<Post>> fetchPosts(int page) {
    if (errors != null) {
      setState(() {
        errors = null;
      });
    }

    return fetcher(page).run().then((value) => value.fold(
          (l) {
            setState(() => errors = l);
            return <Post>[];
          },
          (r) => r,
        ));
  }
}

class PostScope extends ConsumerStatefulWidget {
  const PostScope({
    super.key,
    required this.fetcher,
    required this.builder,
  });

  final PostFetcher fetcher;
  final Widget Function(
    BuildContext context,
    PostGridController<Post> controller,
    BooruError? errors,
  ) builder;

  @override
  ConsumerState<PostScope> createState() => _PostScopeState();
}

class _PostScopeState extends ConsumerState<PostScope> with PostFetcherMixin {
  late final _controller = PostGridController<Post>(
    fetcher: (page) => fetchPosts(page),
    refresher: () => fetchPosts(1),
    pageMode: ref.read(pageModeSettingsProvider),
  );

  @override
  PostFetcher get fetcher => widget.fetcher;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      pageModeSettingsProvider,
      (previous, next) {
        _controller.setPageMode(next);
      },
    );

    return widget.builder(
      context,
      _controller,
      errors,
    );
  }
}
