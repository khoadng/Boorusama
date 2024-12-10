// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/configs/ref.dart';
import 'favorites.dart';

final szurubooruFavoritesProvider = NotifierProvider.family<
    SzurubooruFavoritesNotifier, IMap<int, bool>, BooruConfigAuth>(
  SzurubooruFavoritesNotifier.new,
);

final szurubooruFavoriteProvider =
    Provider.autoDispose.family<bool, int>((ref, postId) {
  final config = ref.watchConfigAuth;
  final favorites = ref.watch(szurubooruFavoritesProvider(config));
  return favorites[postId] ?? false;
});
