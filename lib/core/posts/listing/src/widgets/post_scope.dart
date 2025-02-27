// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../blacklists/providers.dart';
import '../../../../bookmarks/bookmark.dart';
import '../../../../bookmarks/providers.dart';
import '../../../../configs/ref.dart';
import '../../../../settings/providers.dart';
import '../../../post/post.dart';
import 'post_duplicate_checker.dart';
import 'post_grid_controller.dart';

class PostScope<T extends Post> extends ConsumerStatefulWidget {
  const PostScope({
    required this.fetcher,
    required this.builder,
    super.key,
    this.duplicateCheckMode = DuplicateCheckMode.id,
  });

  final PostGridFetcher<T> fetcher;
  final Widget Function(
    BuildContext context,
    PostGridController<T> controller,
  ) builder;

  final DuplicateCheckMode duplicateCheckMode;

  @override
  ConsumerState<PostScope<T>> createState() => _PostScopeState();
}

class _PostScopeState<T extends Post> extends ConsumerState<PostScope<T>> {
  late final _controller = PostGridController<T>(
    fetcher: widget.fetcher,
    duplicateTracker: PostDuplicateTracker<T>(
      mode: widget.duplicateCheckMode,
    ),
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
    ref
      ..listen(
        imageListingSettingsProvider.select((value) => value.pageMode),
        (previous, next) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _controller.setPageMode(next);
          });
        },
      )
      ..listen(
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
