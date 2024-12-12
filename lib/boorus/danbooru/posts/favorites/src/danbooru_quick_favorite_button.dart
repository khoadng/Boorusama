// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/ref.dart';
import '../../../../../core/favorites/providers.dart';
import '../../../../../core/favorites/quick_favorite_button.dart';
import '../../post/post.dart';

class DanbooruQuickFavoriteButton extends ConsumerWidget {
  const DanbooruQuickFavoriteButton({
    super.key,
    required this.post,
  });

  final DanbooruPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(favoritesProvider(ref.watchConfigAuth).notifier);
    final isFaved =
        post.isBanned ? false : ref.watch(favoriteProvider(post.id));

    return QuickFavoriteButton(
      isFaved: isFaved,
      onFavToggle: (isFaved) async {
        if (!isFaved) {
          notifier.remove(post.id);
        } else {
          notifier.add(post.id);
        }
      },
    );
  }
}
