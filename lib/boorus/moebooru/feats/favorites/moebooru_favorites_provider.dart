// Package imports:
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/configs/ref.dart';
import '../../../../core/configs/src/create/providers.dart';
import '../../../../core/configs/src/manage/current_booru_providers.dart';
import '../../../../core/posts/favorites/widgets.dart';
import '../../../../core/posts/post/src/types/post.dart';
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
  });

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
    
    if (!hasData && (forceShowFavoriteStatus ?? false)) {
      notifier.loadFavoriteUsers();
    }

    return canFavorite
        ? QuickFavoriteButton(
            isFaved: ref
                    .watch(moebooruFavoritesProvider(post.id))
                    ?.contains(config.login),
            onFavToggle: (isFaved) async {
              if (isFaved) {
                await ref
                    .read(moebooruClientProvider(config))
                    .favoritePost(postId: post.id)
                    .then((value) {
                  notifier.refresh();
                });
              } else {
                await ref
                    .read(moebooruClientProvider(config))
                    .unfavoritePost(postId: post.id)
                    .then((value) {
                  notifier.refresh();
                });
              }
            },
          )
        : const SizedBox.shrink();
  }
}
