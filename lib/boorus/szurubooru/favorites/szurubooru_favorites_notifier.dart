// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/szurubooru/providers.dart';
import 'package:boorusama/boorus/szurubooru/szurubooru_post.dart';
import 'package:boorusama/clients/szurubooru/szurubooru_client.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/favorites/favorites.dart';
import 'package:boorusama/functional.dart';
import '../post_votes/post_votes.dart';

class SzurubooruFavoritesNotifier
    extends FamilyNotifier<IMap<int, bool>, BooruConfig>
    with FavoritesNotifierMixin {
  @override
  IMap<int, bool> build(BooruConfig arg) {
    ref.watchConfig;

    return <int, bool>{}.lock;
  }

  void preload(List<SzurubooruPost> posts) => preloadInternal(
        posts,
        selfFavorited: (post) => post.ownFavorite,
      );

  SzurubooruClient get client => ref.read(szurubooruClientProvider(arg));

  @override
  Future<AddFavoriteStatus> Function(int postId) get favoriteAdder =>
      (postId) async {
        try {
          await client.addToFavorites(postId: postId);

          await ref
              .read(szurubooruPostVotesProvider(arg).notifier)
              .upvote(postId, localOnly: true);

          return AddFavoriteStatus.success;
        } catch (e) {
          return AddFavoriteStatus.failure;
        }
      };

  @override
  Future<bool> Function(int postId) get favoriteRemover => (postId) async {
        try {
          await client.removeFromFavorites(postId: postId);

          return true;
        } catch (e) {
          return false;
        }
      };

  @override
  IMap<int, bool> get favorites => state;

  @override
  void Function(IMap<int, bool> data) get updateFavorites =>
      (data) => state = data;
}
