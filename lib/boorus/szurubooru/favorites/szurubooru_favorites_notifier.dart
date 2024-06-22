// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/szurubooru/providers.dart';
import 'package:boorusama/boorus/szurubooru/szurubooru_post.dart';
import 'package:boorusama/clients/szurubooru/szurubooru_client.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/favorites/favorites.dart';
import 'package:boorusama/functional.dart';

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
      (postId) => client
          .addToFavorites(postId: postId)
          .then((value) => AddFavoriteStatus.success)
          .catchError((obj) => AddFavoriteStatus.failure);

  @override
  Future<bool> Function(int postId) get favoriteRemover => (postId) => client
      .removeFromFavorites(postId: postId)
      .then((value) => true)
      .catchError((obj) => false);

  @override
  IMap<int, bool> get favorites => state;

  @override
  void Function(IMap<int, bool> data) get updateFavorites =>
      (data) => state = data;
}
