// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/bookmarks/bookmarks.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';

class BookmarkPostButton extends ConsumerWidget {
  const BookmarkPostButton({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watch(currentBooruConfigProvider);
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
                booruConfig.booruId,
                booruConfig.url,
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
