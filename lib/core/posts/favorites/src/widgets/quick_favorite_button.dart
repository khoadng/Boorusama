// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:like_button/like_button.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../configs/config/providers.dart';
import '../../../../settings/providers.dart';
import '../../../../themes/theme/types.dart';
import '../../../post/types.dart';
import '../providers/favorites_notifier.dart';

class QuickFavoriteButton extends ConsumerWidget {
  const QuickFavoriteButton({
    required this.isFaved,
    super.key,
    this.onFavToggle,
  });

  final void Function(bool value)? onFavToggle;
  final bool isFaved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hapticsLevel = ref.watch(hapticFeedbackLevelProvider);

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
          final liked = !isLiked;
          onFavToggle?.call(!isLiked);

          if (liked && hapticsLevel.isBalanceAndAbove) {
            HapticFeedback.mediumImpact();
          }

          return Future.value(liked);
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
    required this.post,
    super.key,
  });

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final notifier = ref.watch(favoritesProvider(config).notifier);
    final canFavorite = ref.watch(canFavoriteProvider(config));

    return canFavorite
        ? QuickFavoriteButton(
            isFaved: ref.watch(favoriteProvider((config, post.id))),
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
