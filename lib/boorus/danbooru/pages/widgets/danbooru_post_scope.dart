// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/error.dart';
import 'post_service_provider_mixin.dart';

typedef DanbooruPostFetcher = DanbooruPostsOrError Function(int page);

mixin DanbooruPostFetcherMixin<T extends StatefulWidget> on State<T> {
  DanbooruPostFetcher get fetcher;

  BooruError? errors;

  Future<List<DanbooruPost>> fetchPosts(int page) {
    if (errors != null) {
      setState(() {
        errors = null;
      });
    }

    return fetcher(page).run().then((value) => value.fold(
          (l) {
            setState(() => errors = l);
            return <DanbooruPost>[];
          },
          (r) => r,
        ));
  }
}

@Deprecated('Will be removed in the future')
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
    fetcher: (page) async {
      final posts = await fetchPosts(page);
      if (!mounted) return <DanbooruPost>[];
      return transform(posts);
    },
    refresher: () async {
      final posts = await fetchPosts(1);
      if (!mounted) return <DanbooruPost>[];
      return transform(posts);
    },
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
