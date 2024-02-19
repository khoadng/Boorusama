// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/szurubooru/providers.dart';
import 'package:boorusama/boorus/szurubooru/szurubooru_post.dart';
import 'package:boorusama/clients/szurubooru/szurubooru_client.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/functional.dart';

class SzurubooruFavoritesNotifier
    extends FamilyNotifier<IMap<int, bool>, BooruConfig> {
  @override
  IMap<int, bool> build(BooruConfig arg) {
    ref.watchConfig;

    return <int, bool>{}.lock;
  }

  void preload(List<SzurubooruPost> posts) => _preload({
        for (final post in posts) post.id: post.ownFavorite,
      });

  void _preload(Map<int, bool> data) {
    state = state.addAll(data.lock);
  }

  Future<void> add(int postId) async {
    if (state[postId] == true) return;

    final success = await addToFavorites(postId);
    if (success) {
      state = state.add(postId, true);
    }
  }

  Future<void> remove(int postId) async {
    if (state[postId] == false) return;

    final success = await removeFromFavorites(postId);
    if (success) {
      state = state.add(postId, false);
    }
  }

  SzurubooruClient get client => ref.read(szurubooruClientProvider(arg));

  Future<bool> addToFavorites(int postId) => client
      .addToFavorites(postId: postId)
      .then((value) => true)
      .catchError((obj) => false);

  Future<bool> removeFromFavorites(int postId) => client
      .removeFromFavorites(postId: postId)
      .then((value) => true)
      .catchError((obj) => false);
}
