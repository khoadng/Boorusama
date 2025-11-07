// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/configs/config/types.dart';
import '../../../../configs/providers.dart';
import '../../../../users/user/providers.dart';
import '../../../listing/providers.dart';
import '../../types.dart';
import '../types/update_order.dart';
import 'local_providers.dart';

final danbooruFavoriteGroupsProvider =
    NotifierProvider.family<
      FavoriteGroupsNotifier,
      List<DanbooruFavoriteGroup>?,
      BooruConfigSearch
    >(
      FavoriteGroupsNotifier.new,
      dependencies: [
        danbooruFavoriteGroupRepoProvider,
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
    final loginDetails = ref.watch(danbooruLoginDetailsProvider(arg.auth));

    if (!loginDetails.hasLogin()) return;
    final groups = await repo.getFavoriteGroupsByCreatorName(
      name: arg.auth.login!,
    );

    //TODO: shouldn't load everything
    final ids = groups
        .map((e) => e.postIds.take(1))
        .expand((e) => e)
        .toSet()
        .toList()
        .take(200)
        .toList();

    unawaited(
      ref.read(danbooruFavoriteGroupPreviewsProvider(arg).notifier).fetch(ids),
    );

    state = groups;
  }

  Future<void> create({
    required BuildContext context,
    required String initialIds,
    required String name,
    required bool isPrivate,
    void Function(String message)? onFailure,
  }) async {
    final t = context.t;
    final currentUser = await ref.read(
      danbooruCurrentUserProvider(arg.auth).future,
    );

    if (currentUser == null) return;

    if (state != null && !currentUser.level.isGoldPlus && state!.length >= 10) {
      onFailure?.call(t.favorite_groups.max_limit_warning);

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
      unawaited(refresh());
    } else {
      onFailure?.call('Fail to create favorite group'.hc);
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
      unawaited(refresh());
    }
  }

  Future<bool> edit({
    required DanbooruFavoriteGroup group,
    String? initialIds,
    String? name,
    bool? isPrivate,
    void Function(String message)? onFailure,
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
      unawaited(refresh());
      return true;
    } else {
      onFailure?.call('Fail to edit favorite group'.hc);
      return false;
    }
  }

  Future<void> addToGroup({
    required BuildContext context,
    required DanbooruFavoriteGroup group,
    required List<int> postIds,
    void Function(String message)? onFailure,
    void Function(DanbooruFavoriteGroup group)? onSuccess,
  }) async {
    final t = context.t;
    final duplicates = postIds.where((e) => group.postIds.contains(e)).toList();

    if (duplicates.isNotEmpty) {
      onFailure?.call(
        t.favorite_groups.duplicate_items_warning_notification,
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
      onSuccess?.call(
        group.copyWith(
          postIds: items,
        ),
      );
      unawaited(refresh());
    } else {
      onFailure?.call('Failed to add posts to favgroup'.hc);
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
      unawaited(refresh());
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
    void Function(String message)? onFailure,
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
