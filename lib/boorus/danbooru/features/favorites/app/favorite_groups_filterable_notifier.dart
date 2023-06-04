// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/features/favorites/favorites.dart';

class FavoriteGroupFilterableNotifier
    extends AutoDisposeNotifier<List<FavoriteGroup>?> {
  @override
  List<FavoriteGroup>? build() {
    return ref.watch(danbooruFavoriteGroupsProvider);
  }

  void filter(String pattern) {
    final data = ref.read(danbooruFavoriteGroupsProvider);
    if (data == null) return;

    if (pattern.isEmpty) {
      state = data;
      return;
    }

    state = data.where((e) => e.name.toLowerCase().contains(pattern)).toList();
  }
}
