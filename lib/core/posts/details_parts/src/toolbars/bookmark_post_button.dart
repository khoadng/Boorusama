// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:like_button/like_button.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../bookmarks/providers.dart';
import '../../../../bookmarks/types.dart';
import '../../../../configs/config/providers.dart';
import '../../../../configs/config/types.dart';
import '../../../../themes/theme/types.dart';
import '../../../../widgets/booru_tooltip.dart';
import '../../../post/types.dart';

class BookmarkPostButton extends ConsumerWidget {
  const BookmarkPostButton({
    required this.post,
    required this.config,
    super.key,
  });

  final Post post;
  final BooruConfigAuth config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkStateAsync = ref.watch(bookmarkProvider);
    final isBookmarked =
        bookmarkStateAsync.valueOrNull?.isBookmarked(
          post,
          config.booruIdHint,
        ) ??
        false;
    final isLoading = bookmarkStateAsync.isLoading;

    return BooruTooltip(
      message: isBookmarked
          ? context.t.post.detail.remove_from_bookmark
          : context.t.post.detail.add_to_bookmark,
      padding: const EdgeInsets.all(8),
      child: isBookmarked
          ? IconButton(
              splashRadius: 16,
              onPressed: isLoading
                  ? null
                  : () {
                      ref.bookmarks.removeBookmarkWithToast(
                        BookmarkUniqueId.fromPost(post, config.booruIdHint),
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
              onPressed: isLoading
                  ? null
                  : () {
                      ref.bookmarks.addBookmarkWithToast(
                        config,
                        post,
                      );
                    },
              icon: const Icon(
                Symbols.bookmark,
              ),
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
    final bookmarkStateAsync = ref.watch(bookmarkProvider);
    final isBookmarked =
        bookmarkStateAsync.valueOrNull?.isBookmarked(
          post,
          booruConfig.booruIdHint,
        ) ??
        false;
    final isLoading = bookmarkStateAsync.isLoading;

    return LikeButton(
      isLiked: isBookmarked,
      onTap: isLoading
          ? null
          : (isLiked) {
              if (isLiked) {
                ref.bookmarks.removeBookmarkWithToast(
                  BookmarkUniqueId.fromPost(post, booruConfig.booruIdHint),
                );
              } else {
                ref.bookmarks.addBookmarkWithToast(
                  booruConfig,
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
    read(bookmarkProvider).whenOrNull(
      data: (bookmarkState) {
        final isBookmarked = bookmarkState.isBookmarked(
          post,
          booruConfig.booruIdHint,
        );

        if (isBookmarked) {
          bookmarks.removeBookmarkWithToast(
            BookmarkUniqueId.fromPost(post, booruConfig.booruIdHint),
          );
        } else {
          bookmarks.addBookmarkWithToast(
            booruConfig,
            post,
          );
        }
      },
    );
  }
}
