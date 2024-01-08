// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/feats/bookmarks/bookmarks.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';

class BookmarkPostButton extends ConsumerWidget {
  const BookmarkPostButton({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watchConfig;
    final bookmarkState = ref.watch(bookmarkProvider);

    final isBookmarked =
        bookmarkState.isBookmarked(post, booruConfig.booruType);

    return isBookmarked
        ? IconButton(
            splashRadius: 16,
            onPressed: () {
              ref.bookmarks.removeBookmarkWithToast(
                bookmarkState.getBookmark(post, booruConfig.booruType)!,
              );
            },
            icon: const Icon(
              Symbols.bookmark,
              fill: 1,
              color: Colors.red,
            ),
          )
        : IconButton(
            splashRadius: 16,
            onPressed: () {
              ref.bookmarks.addBookmarkWithToast(
                booruConfig.booruId,
                booruConfig.url,
                post,
              );
            },
            icon: const Icon(
              Symbols.bookmark,
            ),
          );
  }
}
