// Package imports:
import 'package:booru_clients/szurubooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/posts/favorites/providers.dart';
import '../client_provider.dart';
import '../post_votes/providers.dart';
import '../posts/types.dart';

class SzurubooruFavoriteRepository extends FavoriteRepository<SzurubooruPost> {
  SzurubooruFavoriteRepository(this.ref, this.config);

  final Ref ref;
  final BooruConfigAuth config;

  SzurubooruClient get client => ref.read(szurubooruClientProvider(config));

  @override
  bool canFavorite() => config.hasLoginDetails();

  @override
  Future<AddFavoriteStatus> addToFavorites(int postId) async {
    try {
      await client.addToFavorites(postId: postId);

      await ref
          .read(szurubooruPostVotesProvider(config).notifier)
          .upvote(postId, localOnly: true);

      return AddFavoriteStatus.success;
    } catch (e) {
      return AddFavoriteStatus.failure;
    }
  }

  @override
  Future<bool> removeFromFavorites(int postId) async =>
      client.removeFromFavorites(postId: postId).then((value) => true);

  @override
  bool isPostFavorited(SzurubooruPost post) => post.ownFavorite;
}
