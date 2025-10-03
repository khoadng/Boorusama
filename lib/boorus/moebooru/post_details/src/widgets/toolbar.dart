// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config/providers.dart';
import '../../../../../core/posts/details/details.dart';
import '../../../../../core/posts/details_parts/widgets.dart';
import '../../../../../core/posts/post/post.dart';
import '../../../client_provider.dart';
import '../../../configs/providers.dart';
import '../../../favorites/providers.dart';
import '../../../moebooru.dart';
import '../../../posts/types.dart';

class MoebooruPostDetailsActionToolbar extends ConsumerWidget {
  const MoebooruPostDetailsActionToolbar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final post = InheritedPost.of<MoebooruPost>(context);
    final booru = ref.watch(moebooruProvider);

    return SliverToBoxAdapter(
      child: booru.supportsFavorite(config.url)
          ? _Toolbar<MoebooruPost>(post: post)
          : DefaultPostActionToolbar<MoebooruPost>(post: post),
    );
  }
}

class _Toolbar<T extends Post> extends ConsumerWidget {
  const _Toolbar({
    required this.post,
  });

  final T post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final loginDetails = ref.watch(moebooruLoginDetailsProvider(config));
    final notifier = ref.watch(moebooruFavoritesProvider(post.id).notifier);

    return SimplePostActionToolbar(
      post: post,
      maxVisibleButtons: 4,
      onStartSlideshow: PostDetailsPageViewScope.of(context).startSlideshow,
      isFaved: ref
          .watch(moebooruFavoritesProvider(post.id))
          ?.contains(config.login),
      addFavorite: () => ref
          .read(moebooruClientProvider(config))
          .favoritePost(postId: post.id)
          .then((value) {
            notifier.clear();
          }),
      removeFavorite: () => ref
          .read(moebooruClientProvider(config))
          .unfavoritePost(postId: post.id)
          .then((value) {
            notifier.clear();
          }),
      isAuthorized: loginDetails.hasLogin(),
      forceHideFav: !loginDetails.hasLogin(),
    );
  }
}
