// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'package:boorusama/clients/danbooru/types/types.dart';

const _favGroupLimit = 1000;

class FavoriteGroupRepositoryApi implements FavoriteGroupRepository {
  const FavoriteGroupRepositoryApi({
    required this.client,
  });

  final DanbooruClient client;

  @override
  Future<List<FavoriteGroup>> getFavoriteGroupsByCreatorName({
    required String name,
    int? page,
  }) =>
      client
          .getFavoriteGroups(
            page: page,
            creatorName: name,
            limit: _favGroupLimit,
          )
          .then(
              (groups) => groups.map(favoriteGroupDtoToFavoriteGroup).toList());

  @override
  Future<bool> createFavoriteGroup({
    required String name,
    List<int>? initialItems,
    bool isPrivate = false,
  }) =>
      client
          .postFavoriteGroups(
            name: name,
            postIds: initialItems ?? [],
            isPrivate: isPrivate,
          )
          .then((value) => true)
          .catchError((e) => false);

  @override
  Future<bool> deleteFavoriteGroup({required int id}) => client
      .deleteFavoriteGroup(groupId: id)
      .then((value) => true)
      .catchError((e) => false);

  @override
  Future<bool> addItemsToFavoriteGroup({
    required int id,
    required List<int> itemIds,
  }) =>
      client
          .patchFavoriteGroups(
            groupId: id,
            postIds: itemIds,
          )
          .then((value) => true)
          .catchError((e) => false);

  @override
  Future<bool> removeItemsFromFavoriteGroup({
    required int id,
    required List<int> itemIds,
  }) =>
      client
          .patchFavoriteGroups(
            groupId: id,
            postIds: itemIds,
          )
          .then((value) => true)
          .catchError((e) => false);

  @override
  Future<bool> editFavoriteGroup({
    required int id,
    String? name,
    List<int>? itemIds,
    bool isPrivate = false,
  }) async {
    try {
      return await client
          .patchFavoriteGroups(
            groupId: id,
            name: name,
            isPrivate: isPrivate,
            postIds: itemIds,
          )
          .then((value) => true);
    } on DioException catch (e, stackTrace) {
      if (e.response?.statusCode == 422) {
        Error.throwWithStackTrace(
          Exception(e.response?.data['errors']['base'].first),
          stackTrace,
        );
      } else {
        return Future.value(false);
      }
    }
  }
}

FavoriteGroup favoriteGroupDtoToFavoriteGroup(FavoriteGroupDto d) =>
    FavoriteGroup(
      id: d.id!,
      name: d.name ?? '',
      creator:
          d.creator == null ? Creator.empty() : creatorDtoToCreator(d.creator!),
      createdAt: d.createdAt!,
      updatedAt: d.updatedAt!,
      isPublic: d.isPublic ?? false,
      postIds: d.postIds ?? [],
    );
