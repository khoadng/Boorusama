// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:like_button/like_button.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../bookmarks/providers.dart';
import '../../../../configs/ref.dart';
import '../../../../theme.dart';
import '../../../post/post.dart';

class BookmarkPostButton extends ConsumerWidget {
  const BookmarkPostButton({
    required this.post,
    super.key,
  });

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watchConfigAuth;
    final bookmarkState = ref.watch(bookmarkProvider);

    final isBookmarked =
        bookmarkState.isBookmarked(post, booruConfig.booruType);

    return isBookmarked
        ? IconButton(
            splashRadius: 16,
            onPressed: () {
              ref.bookmarks.removeBookmarkWithToast(
                context,
                bookmarkState.getBookmark(post, booruConfig.booruType)!,
              );
            },
            icon: Icon(
              Symbols.bookmark,
              fill: 1,
              color: context.colors.upvoteColor,
            ),
          )
        : IconButton(
            splashRadius: 16,
            onPressed: () {
              ref.bookmarks.addBookmarkWithToast(
                context,
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

class BookmarkPostLikeButtonButton extends ConsumerWidget {
  const BookmarkPostLikeButtonButton({
    required this.post,
    super.key,
  });

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watchConfigAuth;
    final bookmarkState = ref.watch(bookmarkProvider);

    final isBookmarked =
        bookmarkState.isBookmarked(post, booruConfig.booruType);

    return LikeButton(
      isLiked: isBookmarked,
      onTap: (isLiked) {
        if (isLiked) {
          ref.bookmarks.removeBookmarkWithToast(
            context,
            bookmarkState.getBookmark(post, booruConfig.booruType)!,
          );
        } else {
          ref.bookmarks.addBookmarkWithToast(
            context,
            booruConfig.booruId,
            booruConfig.url,
            post,
          );
        }

        return Future.value(!isLiked);
      },
      likeBuilder: (isLiked) {
        return Icon(
          isLiked ? Symbols.bookmark : Symbols.bookmark,
          color: isLiked
              ? context.colors.upvoteColor
              : context.extendedColorScheme.onSurfaceContainerOverlay,
          fill: isLiked ? 1 : 0,
        );
      },
    );
  }
}

extension BookmarkPostX on WidgetRef {
  void toggleBookmark(Post post) {
    final booruConfig = readConfigAuth;
    final bookmarkState = read(bookmarkProvider);

    final isBookmarked =
        bookmarkState.isBookmarked(post, booruConfig.booruType);

    if (isBookmarked) {
      bookmarks.removeBookmarkWithToast(
        context,
        bookmarkState.getBookmark(post, booruConfig.booruType)!,
      );
    } else {
      bookmarks.addBookmarkWithToast(
        context,
        booruConfig.booruId,
        booruConfig.url,
        post,
      );
    }
  }
}
