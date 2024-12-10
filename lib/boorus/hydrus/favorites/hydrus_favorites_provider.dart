// Package imports:
import 'package:booru_clients/hydrus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/configs/ref.dart';
import '../hydrus.dart';
import 'favorites.dart';

final hydrusFavoritesProvider = NotifierProvider.family<HydrusFavoritesNotifier,
    IMap<int, bool>, BooruConfigAuth>(
  HydrusFavoritesNotifier.new,
);

final hydrusFavoriteProvider =
    Provider.autoDispose.family<bool, int>((ref, postId) {
  final config = ref.watchConfigAuth;
  final favorites = ref.watch(hydrusFavoritesProvider(config));
  return favorites[postId] ?? false;
});

final hydrusCanFavoriteProvider =
    FutureProvider.family<bool, BooruConfigAuth>((ref, config) async {
  final client = ref.watch(hydrusClientProvider(config));

  final services = await client.getServicesCached();

  return getLikeDislikeRatingKey(services) != null;
});
