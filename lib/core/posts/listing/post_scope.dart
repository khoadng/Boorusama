// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/bookmarks/bookmarks.dart';
import 'package:boorusama/core/configs/providers.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/settings/settings.dart';
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
  ) builder;

  @override
  ConsumerState<PostScope<T>> createState() => _PostScopeState();
}

class _PostScopeState<T extends Post> extends ConsumerState<PostScope<T>> {
  late final _controller = PostGridController<T>(
    fetcher: widget.fetcher,
    blacklistedTagsFetcher: () {
      if (!mounted) return Future.value({});

      return ref.read(blacklistTagsProvider(ref.readConfigAuth).future);
    },
    pageMode: ref
        .read(imageListingSettingsProvider.select((value) => value.pageMode)),
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
    mountedChecker: () => mounted,
  );

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      imageListingSettingsProvider.select((value) => value.pageMode),
      (previous, next) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _controller.setPageMode(next);
        });
      },
    );

    ref.listen(
      blacklistTagsProvider(ref.watchConfigAuth),
      (previous, next) {
        if (previous != next) {
          next.when(
            data: (tags) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _controller.setBlacklistedTags(tags);
              });
            },
            error: (error, st) {},
            loading: () {},
          );
        }
      },
    );

    return widget.builder(
      context,
      _controller,
    );
  }
}
