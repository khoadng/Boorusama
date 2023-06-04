// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/core/bookmarks/bookmark_notifier.dart';
import 'package:boorusama/core/boorus/providers.dart';
import 'package:boorusama/core/domain/posts.dart';

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
            onPressed: () {
              ref.bookmarks.removeBookmarkWithToast(
                bookmarkState.getBookmark(post, booru.booruType)!,
              );
            },
            icon: const FaIcon(
              FontAwesomeIcons.solidBookmark,
              color: Colors.red,
            ),
          )
        : IconButton(
            onPressed: () {
              ref.bookmarks.addBookmarkWithToast(
                "",
                booru,
                post,
              );
            },
            icon: const FaIcon(FontAwesomeIcons.bookmark),
          );
  }
}
