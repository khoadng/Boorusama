// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/bookmarks/bookmark_notifier.dart';
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';

class BookmarkPostButton extends ConsumerWidget {
  const BookmarkPostButton({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booru = ref.watch(currentBooruProvider);
    final bookmarkState = ref.watch(bookmarkProvider);

    final isBookmarked = bookmarkState.isBookmarked(post, booru.booruType);

    return isBookmarked
        ? IconButton(
            splashRadius: 16,
            onPressed: () {
              ref.bookmarks.removeBookmarkWithToast(
                bookmarkState.getBookmark(post, booru.booruType)!,
              );
            },
            icon: const FaIcon(
              FontAwesomeIcons.solidBookmark,
              color: Colors.red,
              size: 20,
            ),
          )
        : IconButton(
            splashRadius: 16,
            onPressed: () {
              ref.bookmarks.addBookmarkWithToast(
                "",
                booru,
                post,
              );
            },
            icon: const FaIcon(
              FontAwesomeIcons.bookmark,
              size: 20,
            ),
          );
  }
}
