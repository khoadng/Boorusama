// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:like_button/like_button.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../configs/ref.dart';
import '../posts/post/post.dart';
import '../theme.dart';
import 'favorites_notifier.dart';

class QuickFavoriteButton extends ConsumerWidget {
  const QuickFavoriteButton({
    super.key,
    this.onFavToggle,
    required this.isFaved,
  });

  final void Function(bool value)? onFavToggle;
  final bool isFaved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.only(
        top: 2,
        bottom: 1,
        right: 1,
        left: 3,
      ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.extendedColorScheme.surfaceContainerOverlay,
      ),
      child: LikeButton(
        isLiked: isFaved,
        onTap: (isLiked) {
          onFavToggle?.call(!isLiked);

          return Future.value(!isLiked);
        },
        likeBuilder: (isLiked) {
          return Icon(
            isLiked ? Symbols.favorite : Symbols.favorite,
            color: isLiked
                ? context.colors.upvoteColor
                : context.extendedColorScheme.onSurfaceContainerOverlay,
            fill: isLiked ? 1 : 0,
          );
        },
      ),
    );
  }
}

class DefaultQuickFavoriteButton extends ConsumerWidget {
  const DefaultQuickFavoriteButton({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final notifier = ref.watch(favoritesProvider(config).notifier);
    final canFavorite = ref.watch(canFavoriteProvider(config));

    return canFavorite
        ? QuickFavoriteButton(
            isFaved: ref.watch(favoriteProvider(post.id)),
            onFavToggle: (isFaved) async {
              if (isFaved) {
                await notifier.add(post.id);
              } else {
                await notifier.remove(post.id);
              }
            },
          )
        : const SizedBox.shrink();
  }
}
