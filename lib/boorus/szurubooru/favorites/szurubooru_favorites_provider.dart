// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/functional.dart';
import 'favorites.dart';

final szurubooruFavoritesProvider = NotifierProvider.family<
    SzurubooruFavoritesNotifier, IMap<int, bool>, BooruConfig>(
  SzurubooruFavoritesNotifier.new,
);

final szurubooruFavoriteProvider =
    Provider.autoDispose.family<bool, int>((ref, postId) {
  final config = ref.watchConfig;
  final favorites = ref.watch(szurubooruFavoritesProvider(config));
  return favorites[postId] ?? false;
});
