// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/config/types.dart';
import '../../types.dart';
import 'favorite_groups_notifier.dart';

final danbooruFavoriteGroupFilterableProvider = NotifierProvider.autoDispose
    .family<
      FavoriteGroupFilterableNotifier,
      List<DanbooruFavoriteGroup>?,
      BooruConfigSearch
    >(
      FavoriteGroupFilterableNotifier.new,
      dependencies: [
        danbooruFavoriteGroupsProvider,
      ],
    );

class FavoriteGroupFilterableNotifier
    extends
        AutoDisposeFamilyNotifier<
          List<DanbooruFavoriteGroup>?,
          BooruConfigSearch
        > {
  @override
  List<DanbooruFavoriteGroup>? build(BooruConfigSearch arg) {
    return ref.watch(danbooruFavoriteGroupsProvider(arg));
  }

  void filter(String pattern) {
    final data = ref.read(danbooruFavoriteGroupsProvider(arg));
    if (data == null) return;

    if (pattern.isEmpty) {
      state = data;
      return;
    }

    state = data.where((e) => e.name.toLowerCase().contains(pattern)).toList();
  }
}
