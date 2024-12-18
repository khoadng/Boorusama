// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'favorite_tags_sort_type.dart';

final selectedFavoriteTagQueryProvider =
    StateProvider.autoDispose<String>((ref) {
  return '';
});

final selectedFavoriteTagsSortTypeProvider =
    StateProvider.autoDispose<FavoriteTagsSortType>((ref) {
  return FavoriteTagsSortType.recentlyAdded;
});
