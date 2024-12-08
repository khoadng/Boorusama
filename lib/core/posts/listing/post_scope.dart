// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/bookmarks/bookmark.dart';
import 'package:boorusama/core/bookmarks/bookmark_provider.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/settings/data.dart';
import 'package:boorusama/core/settings/data/listing_provider.dart';
import '../post.dart';
import 'post_grid_controller.dart';

class PostScope<T extends Post> extends ConsumerStatefulWidget {
  const PostScope({
    super.key,
    required this.fetcher,
    required this.builder,
  });

  final PostGridFetcher<T> fetcher;
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
            : const IMap<String, Bookmark>.empty();

        return bookmarks.keys.toSet();
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
