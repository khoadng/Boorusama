// Package imports:
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:like_button/like_button.dart';
import 'package:material_symbols_icons/symbols.dart';
// Project imports:
import '../../../../core/configs/ref.dart';
import '../../../../core/configs/src/manage/current_booru_providers.dart';
import '../../../../core/posts/post/src/types/post.dart';
import '../../../../core/theme/theme.dart';
import '../../moebooru.dart';
import 'moebooru_favorites_notifier.dart';

final moebooruFavoritesProvider =
    NotifierProvider.family<MoebooruFavoritesNotifier, Set<String>?, int>(
  MoebooruFavoritesNotifier.new,
);

class MoebooruQuickFavoriteButton extends ConsumerWidget {
  const MoebooruQuickFavoriteButton({
    required this.post,
    super.key,
    this.isFaved,
  });

  final bool? isFaved;
  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final notifier = ref.watch(moebooruFavoritesProvider(post.id).notifier);
    final canFavorite = config.hasLoginDetails();
    final hasData = ref.watch(moebooruFavoritesProvider(post.id)) != null;
    final forceShowFavoriteStatus = ref.watch(
      currentReadOnlyBooruConfigProvider.select(
        (value) => value.forceShowFavoriteStatus,
      ),
    );

    final shouldShow = canFavorite && (forceShowFavoriteStatus == true);

    if (!shouldShow) {
      return const SizedBox.shrink();
    }

    if (!hasData) {
      notifier.loadFavoriteUsers();
    }

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
        isLiked: isFaved ?? false,
        onTap: (isLiked) {
          final val = isFaved == null ? true : !isLiked;
          if (val) {
            ref
                .read(moebooruClientProvider(config))
                .favoritePost(postId: post.id)
                .then((value) {
              notifier.refresh();
            });
          } else {
            ref
                .read(moebooruClientProvider(config))
                .unfavoritePost(postId: post.id)
                .then((value) {
              notifier.refresh();
            });
          }
          return Future.value(val);
        },
        likeBuilder: (isLiked) {
          if (!isLiked && isFaved == null) {
            return Icon(
              Symbols.heart_plus,
              color: context.extendedColorScheme.onSurfaceContainerOverlay,
              fill: 1,
            );
          }
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
