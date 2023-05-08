// Flutter imports:
import 'package:boorusama/core/application/settings/settings_notifier.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/posts.dart';
import 'package:boorusama/core/domain/error.dart';
import 'package:boorusama/core/ui/post_grid_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef DanbooruPostFetcher = DanbooruPostsOrError Function(int page);

mixin DanbooruPostFetcherMixin<T extends StatefulWidget> on State<T> {
  DanbooruPostFetcher get fetcher;

  BooruError? errors;

  Future<List<DanbooruPost>> fetchPosts(int page) =>
      fetcher(page).run().then((value) => value.fold(
            (l) {
              setState(() => errors = l);
              return <DanbooruPost>[];
            },
            (r) => r,
          ));
}

class DanbooruPostScope extends ConsumerStatefulWidget {
  const DanbooruPostScope({
    super.key,
    required this.fetcher,
    required this.builder,
  });

  final DanbooruPostFetcher fetcher;
  final Widget Function(
    BuildContext context,
    PostGridController<DanbooruPost> controller,
    BooruError? errors,
  ) builder;

  @override
  ConsumerState<DanbooruPostScope> createState() => _DanbooruPostScopeState();
}

class _DanbooruPostScopeState extends ConsumerState<DanbooruPostScope>
    with
        DanbooruPostTransformMixin,
        DanbooruPostServiceProviderMixin,
        DanbooruPostFetcherMixin {
  late final _controller = PostGridController<DanbooruPost>(
    fetcher: (page) => fetchPosts(page).then(transform),
    refresher: () => fetchPosts(1).then(transform),
    pageMode: ref.read(pageModeSettingsProvider),
  );

  @override
  DanbooruPostFetcher get fetcher => widget.fetcher;

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
