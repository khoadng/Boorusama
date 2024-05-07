// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/bookmarks/bookmarks.dart';
import 'package:boorusama/core/feats/boorus/providers.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/functional.dart';

typedef PostScopeFetcher<T extends Post> = PostsOrErrorCore<T> Function(
    int page);

class PostScope<T extends Post> extends ConsumerStatefulWidget {
  const PostScope({
    super.key,
    required this.fetcher,
    required this.builder,
  });

  final PostScopeFetcher<T> fetcher;
  final Widget Function(
    BuildContext context,
    PostGridController<T> controller,
    BooruError? errors,
  ) builder;

  @override
  ConsumerState<PostScope<T>> createState() => _PostScopeState();
}

class _PostScopeState<T extends Post> extends ConsumerState<PostScope<T>> {
  late final _controller = PostGridController<T>(
    fetcher: (page) => fetchPosts(page),
    refresher: () => fetchPosts(1),
    pageMode: ref.read(pageModeSettingsProvider),
    blacklistedTags: ref.read(blacklistTagsProvider(ref.readConfig)),
    blacklistedUrlsFetcher: () {
      try {
        final settings = ref.read(settingsProvider);

        final bookmarks = settings.shouldFilterBookmarks
            ? ref.read(bookmarkProvider).bookmarks
            : <Bookmark>[].lock;

        return bookmarks.map((e) => e.originalUrl).toSet();
      } catch (_) {
        return {};
      }
    },
  );

  BooruError? errors;

  Future<List<T>> fetchPosts(int page) {
    if (errors != null) {
      setState(() {
        errors = null;
      });
    }

    return widget.fetcher(page).run().then((value) => value.fold(
          (l) {
            if (mounted) {
              setState(() => errors = l);
            }
            return <T>[];
          },
          (r) => r,
        ));
  }

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

    ref.listen(
      blacklistTagsProvider(ref.watchConfig),
      (previous, next) {
        if (previous != next) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _controller.setBlacklistedTags(next);
          });
        }
      },
    );

    return widget.builder(
      context,
      _controller,
      errors,
    );
  }
}
