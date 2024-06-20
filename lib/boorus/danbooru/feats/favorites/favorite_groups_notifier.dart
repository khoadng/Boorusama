// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/core/configs/configs.dart';

class FavoriteGroupsNotifier
    extends FamilyNotifier<List<FavoriteGroup>?, BooruConfig> {
  @override
  List<FavoriteGroup>? build(BooruConfig arg) {
    refresh();
    return null;
  }

  FavoriteGroupRepository get repo =>
      ref.read(danbooruFavoriteGroupRepoProvider(arg));

  Future<void> refresh() async {
    if (!arg.hasLoginDetails()) return;
    final groups = await repo.getFavoriteGroupsByCreatorName(name: arg.login!);

    //TODO: shouldn't load everything
    final ids = groups
        .map((e) => e.postIds.take(1))
        .expand((e) => e)
        .toSet()
        .toList()
        .take(200)
        .toList();

    ref.read(danbooruFavoriteGroupPreviewsProvider(arg).notifier).fetch(ids);

    state = groups;
  }

  Future<void> create({
    required String initialIds,
    required String name,
    required bool isPrivate,
    void Function(String message, bool translatable)? onFailure,
  }) async {
    final currentUser = await ref.read(danbooruCurrentUserProvider(arg).future);

    if (currentUser == null) return;

    if (state != null &&
        !isBooruGoldPlusAccount(currentUser.level) &&
        state!.length >= 10) {
      onFailure?.call('favorite_groups.max_limit_warning', true);

      return;
    }

    final idString = initialIds.split(' ');
    final ids = idString.map((e) => int.tryParse(e)).toList();

    final validIds = ids.whereNotNull().toList();

    final success = await repo.createFavoriteGroup(
      name: name,
      initialItems: validIds,
      isPrivate: isPrivate,
    );

    if (success) {
      refresh();
    } else {
      onFailure?.call('Fail to create favorite group', false);
    }
  }

  // delete a favorite group
  Future<void> delete({
    required FavoriteGroup group,
  }) async {
    final success = await repo.deleteFavoriteGroup(
      id: group.id,
    );

    if (success) {
      refresh();
    }
  }

  Future<void> edit({
    required FavoriteGroup group,
    String? initialIds,
    String? name,
    bool? isPrivate,
    void Function(String message, bool translatable)? onFailure,
  }) async {
    final idString = initialIds?.split(' ') ?? [];
    final ids = idString
        .map(
          (e) => int.tryParse(e),
        )
        .toList();

    final validIds = ids.whereNotNull().toList();
    final success = await repo.editFavoriteGroup(
      id: group.id,
      name: name ?? group.name,
      itemIds: initialIds != null ? validIds : null,
      isPrivate: isPrivate ?? !group.isPublic,
    );

    if (success) {
      refresh();
    } else {
      onFailure?.call('Fail to edit favorite group', false);
    }
  }

  Future<void> addToGroup({
    required FavoriteGroup group,
    required List<int> postIds,
    void Function(String message, bool translatable)? onFailure,
    void Function(FavoriteGroup group)? onSuccess,
  }) async {
    final duplicates = postIds.where((e) => group.postIds.contains(e)).toList();

    if (duplicates.isNotEmpty) {
      onFailure?.call(
        'favorite_groups.duplicate_items_warning_notification',
        true,
      );

      return;
    }

    final items = [
      ...group.postIds,
      ...postIds,
    ];

    final success = await repo.addItemsToFavoriteGroup(
      id: group.id,
      itemIds: items,
    );

    if (success) {
      onSuccess?.call(group.copyWith(
        postIds: items,
      ));
      refresh();
    } else {
      onFailure?.call('Failed to add posts to favgroup', false);
    }
  }

  Future<void> removeFromGroup({
    required FavoriteGroup group,
    required List<int> postIds,
    void Function(String message, bool translatable)? onFailure,
    void Function(FavoriteGroup group)? onSuccess,
  }) async {
    final items = [...group.postIds]
      ..removeWhere((element) => postIds.contains(element));

    final success = await repo.removeItemsFromFavoriteGroup(
      id: group.id,
      itemIds: items,
    );

    if (success) {
      onSuccess?.call(group.copyWith(postIds: items));
      refresh();
    } else {
      onFailure?.call('Failed to remove posts to favgroup', false);
    }
  }
}

class FavoriteGroupPreviewsNotifier
    extends FamilyNotifier<Map<int, String>, BooruConfig> {
  @override
  Map<int, String> build(BooruConfig arg) {
    return {};
  }

  Future<void> fetch(List<int> postIds) async {
    // check if the postIds are already cached, if so, don't fetch them again
    final cachedPostIds = state.keys.toList();
    final postIdsToFetch = postIds.where((id) => !cachedPostIds.contains(id));
    if (postIdsToFetch.isEmpty) return;

    final posts = await ref
        .watch(danbooruPostRepoProvider(arg))
        .getPostsFromIds(postIdsToFetch.toList())
        .run()
        .then((value) => value.fold(
              (l) => <DanbooruPost>[],
              (r) => r,
            ));

    final map = {for (final p in posts) p.id: p.thumbnailImageUrl};

    // merge the new map with the old one
    state = {...state, ...map};
  }
}
