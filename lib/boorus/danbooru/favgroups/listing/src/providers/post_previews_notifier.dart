// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../core/configs/config/types.dart';
import '../../../../../../core/posts/post/types.dart';
import '../../../../posts/post/providers.dart';
import '../../../../posts/post/types.dart';

final danbooruFavoriteGroupPreviewsProvider =
    NotifierProvider.family<
      FavoriteGroupPreviewsNotifier,
      Map<int, String>,
      BooruConfigSearch
    >(
      FavoriteGroupPreviewsNotifier.new,
      dependencies: [
        danbooruPostRepoProvider,
      ],
    );

final danbooruFavoriteGroupPreviewProvider = Provider.autoDispose
    .family<String, int?>((ref, postId) {
      final config = ref.watchConfigSearch;
      return ref.watch(danbooruFavoriteGroupPreviewsProvider(config))[postId] ??
          '';
    });

class FavoriteGroupPreviewsNotifier
    extends FamilyNotifier<Map<int, String>, BooruConfigSearch> {
  @override
  Map<int, String> build(BooruConfigSearch arg) {
    return {};
  }

  Future<void> fetch(List<int> postIds) async {
    // check if the postIds are already cached, if so, don't fetch them again
    final cachedPostIds = state.keys.toList();
    final postIdsToFetch = postIds.where((id) => !cachedPostIds.contains(id));
    if (postIdsToFetch.isEmpty) return;

    final r = await ref
        .watch(danbooruPostRepoProvider(arg))
        .getPostsFromIds(postIdsToFetch.toList())
        .run()
        .then(
          (value) => value.fold(
            (l) => <DanbooruPost>[].toResult(),
            (r) => r,
          ),
        );

    final map = {for (final p in r.posts) p.id: p.thumbnailImageUrl};

    // merge the new map with the old one
    state = {...state, ...map};
  }
}
