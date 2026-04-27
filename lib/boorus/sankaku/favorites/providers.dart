// Package imports:
import 'package:booru_clients/sankaku.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../client_provider.dart';
import '../posts/types.dart';

final sankakuFavoritesProvider =
    NotifierProvider.family<
      SankakuFavoritesNotifier,
      IMap<SankakuId, bool>,
      BooruConfigAuth
    >(SankakuFavoritesNotifier.new);

final sankakuFavoriteProvider = Provider.autoDispose
    .family<bool, (BooruConfigAuth, SankakuId)>(
      (ref, params) {
        final (config, postId) = params;
        return ref.watch(sankakuFavoritesProvider(config))[postId] ?? false;
      },
    );

final sankakuCanFavoriteProvider = Provider.family<bool, BooruConfigAuth>((
  ref,
  config,
) {
  final url = config.url.toLowerCase();
  final isIdol = url.contains('idol.') || url.contains('idolcomplex');

  if (isIdol) return false;

  final login = config.login;
  final password = config.apiKey;

  return login != null &&
      login.isNotEmpty &&
      password != null &&
      password.isNotEmpty;
});

class SankakuFavoritesNotifier
    extends FamilyNotifier<IMap<SankakuId, bool>, BooruConfigAuth> {
  @override
  IMap<SankakuId, bool> build(BooruConfigAuth arg) {
    return <SankakuId, bool>{}.lock;
  }

  SankakuClient get client => ref.read(sankakuClientProvider(arg));

  void preload(List<SankakuPost> posts) {
    final cache = state.unlock;

    for (final post in posts) {
      final id = post.sankakuId;

      if (id == null) continue;

      cache[id] = post.isFavorited;
    }

    state = cache.lock;
  }

  Future<void> add(SankakuPost post) async {
    final id = post.sankakuId;

    if (id == null || (state[id] ?? false)) return;

    state = state.add(id, true);

    final success = await client.addToFavorites(postId: id);
    if (!success) {
      state = state.add(id, false);
    }
  }

  Future<void> remove(SankakuPost post) async {
    final id = post.sankakuId;

    if (id == null || state[id] == false) return;

    state = state.add(id, false);

    final success = await client.removeFromFavorites(postId: id);
    if (!success) {
      state = state.add(id, true);
    }
  }
}
