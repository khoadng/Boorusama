// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs.dart';
import 'package:boorusama/core/configs/manage.dart';
import '../users/level/user_level.dart';
import '../users/user/providers.dart';
import 'danbooru_favorite_group.dart';
import 'favorite_group_previews_notifier.dart';
import 'favorite_group_repository.dart';
import 'providers.dart';

final danbooruFavoriteGroupsProvider = NotifierProvider.family<
    FavoriteGroupsNotifier, List<DanbooruFavoriteGroup>?, BooruConfigSearch>(
  FavoriteGroupsNotifier.new,
  dependencies: [
    danbooruFavoriteGroupRepoProvider,
    currentBooruConfigProvider,
    danbooruCurrentUserProvider,
  ],
);

class FavoriteGroupsNotifier
    extends FamilyNotifier<List<DanbooruFavoriteGroup>?, BooruConfigSearch> {
  @override
  List<DanbooruFavoriteGroup>? build(BooruConfigSearch arg) {
    refresh();
    return null;
  }

  FavoriteGroupRepository get repo =>
      ref.read(danbooruFavoriteGroupRepoProvider(arg.auth));

  Future<void> refresh() async {
    if (!arg.auth.hasLoginDetails()) return;
    final groups =
        await repo.getFavoriteGroupsByCreatorName(name: arg.auth.login!);

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
    final currentUser =
        await ref.read(danbooruCurrentUserProvider(arg.auth).future);

    if (currentUser == null) return;

    if (state != null &&
        !isBooruGoldPlusAccount(currentUser.level) &&
        state!.length >= 10) {
      onFailure?.call('favorite_groups.max_limit_warning', true);

      return;
    }

    final idString = initialIds.split(' ');
    final ids = idString.map((e) => int.tryParse(e)).toList();

    final validIds = ids.nonNulls.toList();

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
    required DanbooruFavoriteGroup group,
  }) async {
    final success = await repo.deleteFavoriteGroup(
      id: group.id,
    );

    if (success) {
      refresh();
    }
  }

  Future<bool> edit({
    required DanbooruFavoriteGroup group,
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

    final validIds = ids.nonNulls.toList();
    final success = await repo.editFavoriteGroup(
      id: group.id,
      name: name ?? group.name,
      itemIds: initialIds != null ? validIds : null,
      isPrivate: isPrivate ?? !group.isPublic,
    );

    if (success) {
      refresh();
      return true;
    } else {
      onFailure?.call('Fail to edit favorite group', false);
      return false;
    }
  }

  Future<void> addToGroup({
    required DanbooruFavoriteGroup group,
    required List<int> postIds,
    void Function(String message, bool translatable)? onFailure,
    void Function(DanbooruFavoriteGroup group)? onSuccess,
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
    required DanbooruFavoriteGroup group,
    required List<int> postIds,
    void Function(String message, bool translatable)? onFailure,
    void Function(DanbooruFavoriteGroup group)? onSuccess,
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

extension FavoriteGroupsNotifierX on FavoriteGroupsNotifier {
  Future<List<int>?> editIds({
    required DanbooruFavoriteGroup group,
    required Set<int> newIds,
    required Set<int> oldIds,
    required Set<int> allIds,
    void Function(String message, bool translatable)? onFailure,
  }) async {
    final updatedIds = updateOrder(allIds, oldIds, newIds);

    final success = await edit(
      group: group,
      initialIds: updatedIds.join(' '),
      onFailure: onFailure,
    );

    return success ? updatedIds : null;
  }
}

List<int> updateOrder(
  Set<int> allIds,
  Set<int> oldIds,
  Set<int> newIds,
) {
  // Handle empty inputs
  if (allIds.isEmpty) return [];
  if (oldIds.isEmpty) return allIds.toList();
  if (newIds.isEmpty) return []; // If newIds is empty, everything is deleted

  // Validate that oldIds and newIds are subsets of allIds
  if (!oldIds.every((id) => allIds.contains(id)) ||
      !newIds.every((id) => allIds.contains(id))) {
    return allIds.toList(); // Return original order if invalid IDs found
  }

  final allIdString = allIds.join(' ');
  final oldIdString = oldIds.join(' ');

  // Make sure sequence of IDs is the same
  if (!allIdString.contains(oldIdString)) {
    throw ArgumentError('Old IDs are not have the same sequence as all IDs');
  }

  // Remove any IDs in newIds that are not in oldIds
  final validNewIds = newIds.where((id) => oldIds.contains(id)).toSet();

  // Convert allIds to list and remove deleted items
  final toDelete = oldIds.difference(validNewIds);
  final result = allIds.where((id) => !toDelete.contains(id)).toList();

  // Check if there's any intersection between old and new IDs
  if (oldIds.intersection(validNewIds).isEmpty) return result;

  // Find the start index of the section to reorder
  final firstOldId = oldIds.firstWhere(
    (id) => result.contains(id),
    orElse: () => result.first,
  );
  final startIndex = result.indexOf(firstOldId);

  // Replace section with new order
  final newIdsOrdered = validNewIds.toList();
  for (var i = 0;
      i < newIdsOrdered.length && (startIndex + i) < result.length;
      i++) {
    result[startIndex + i] = newIdsOrdered[i];
  }

  return result;
}
