// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/favorites.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/domain/boorus.dart';

final danbooruFavoriteGroupPreviewProvider = Provider.autoDispose
    .family<String, int?>((ref, postId) =>
        ref.watch(danbooruFavoriteGroupPreviewsProvider)[postId] ?? '');

final danbooruFavoriteGroupPreviewsProvider =
    NotifierProvider<FavoriteGroupPreviewsNotifier, Map<int, String>>(
  FavoriteGroupPreviewsNotifier.new,
  dependencies: [
    danbooruPostRepoProvider,
  ],
);

final danbooruFavoriteGroupsProvider =
    NotifierProvider<FavoriteGroupsNotifier, List<FavoriteGroup>>(
  FavoriteGroupsNotifier.new,
  dependencies: [
    danbooruFavoriteGroupRepoProvider,
    currentBooruConfigProvider,
  ],
);

class FavoriteGroupsNotifier extends Notifier<List<FavoriteGroup>> {
  @override
  List<FavoriteGroup> build() {
    refresh();
    return [];
  }

  Future<void> refresh() async {
    final currentUser = ref.watch(currentBooruConfigProvider);
    if (!currentUser.hasLoginDetails()) return;
    final groups = await ref
        .watch(danbooruFavoriteGroupRepoProvider)
        .getFavoriteGroupsByCreatorName(name: currentUser.login!);

    //TODO: shouldn't load everything
    final ids = groups
        .map((e) => e.postIds.take(1))
        .expand((e) => e)
        .toSet()
        .toList()
        .take(200)
        .toList();

    ref.read(danbooruFavoriteGroupPreviewsProvider.notifier).fetch(ids);

    state = groups;
  }
}

class FavoriteGroupPreviewsNotifier extends Notifier<Map<int, String>> {
  @override
  Map<int, String> build() {
    return {};
  }

  Future<void> fetch(List<int> postIds) async {
    // check if the postIds are already cached, if so, don't fetch them again
    final cachedPostIds = state.keys.toList();
    final postIdsToFetch = postIds.where((id) => !cachedPostIds.contains(id));
    if (postIdsToFetch.isEmpty) return;

    final posts = await ref
        .watch(danbooruPostRepoProvider)
        .getPostsFromIds(postIdsToFetch.toList())
        .run()
        .then((value) => value.fold(
              (l) => <DanbooruPost>[],
              (r) => r,
            ));

    final map = {for (final p in posts) p.id: p.thumbnailImageUrl};

    state = map;
  }
}
