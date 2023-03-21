// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

// Project imports:
import 'package:boorusama/api/danbooru/danbooru.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites.dart';
import 'package:boorusama/boorus/danbooru/infra/dtos/dtos.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/infra/http_parser.dart';

const favoriteGroupApiParams =
    'id,name,post_ids,created_at,updated_at,is_public,creator';

const _favGroupLimit = 1000;

List<FavoriteGroup> parseFavoriteGroups(HttpResponse<dynamic> value) => parse(
      value: value,
      converter: (item) => FavoriteGroupDto.fromJson(item),
    ).map(favoriteGroupDtoToFavoriteGroup).toList();

class FavoriteGroupRepositoryApi implements FavoriteGroupRepository {
  const FavoriteGroupRepositoryApi({
    required this.api,
    required this.currentUserBooruRepository,
  });

  final DanbooruApi api;
  final CurrentUserBooruRepository currentUserBooruRepository;

  @override
  Future<List<FavoriteGroup>> getFavoriteGroups({
    String? name,
    int? page,
  }) =>
      currentUserBooruRepository
          .get()
          .then(
            (userBooru) => api.getFavoriteGroups(
              userBooru?.login,
              userBooru?.apiKey,
              namePattern: name,
              page: page,
              only: favoriteGroupApiParams,
              limit: 50,
            ),
          )
          .then(parseFavoriteGroups);

  @override
  Future<List<FavoriteGroup>> getFavoriteGroupsByCreatorName({
    required String name,
    int? page,
  }) =>
      currentUserBooruRepository.get().then(
        (userBooru) {
          return api.getFavoriteGroups(
            userBooru?.login,
            userBooru?.apiKey,
            page: page,
            creatorName: name,
            only: favoriteGroupApiParams,
            limit: _favGroupLimit,
          );
        },
      ).then(parseFavoriteGroups);

  @override
  Future<bool> createFavoriteGroup({
    required String name,
    List<int>? initialItems,
    bool isPrivate = false,
  }) =>
      currentUserBooruRepository
          .get()
          .then((userBooru) => api.postFavoriteGroups(
                userBooru?.login,
                userBooru?.apiKey,
                name: name,
                postIdsString: initialItems?.join(' '),
                isPrivate: isPrivate,
              ))
          .then((value) {
        return [302, 201].contains(value.response.statusCode);
      });

  @override
  Future<bool> deleteFavoriteGroup({required int id}) =>
      currentUserBooruRepository
          .get()
          .then((userBooru) => api.deleteFavoriteGroup(
                userBooru?.login,
                userBooru?.apiKey,
                id,
              ))
          .then((value) {
        return [302, 204].contains(value.response.statusCode);
      });

  @override
  Future<bool> addItemsToFavoriteGroup({
    required int id,
    required List<int> itemIds,
  }) =>
      currentUserBooruRepository
          .get()
          .then((userBooru) => api.patchFavoriteGroups(
                userBooru?.login,
                userBooru?.apiKey,
                id,
                postIdsString: itemIds.join(' '),
              ))
          .then((value) {
        return [302, 204].contains(value.response.statusCode);
      });

  @override
  Future<bool> removeItemsFromFavoriteGroup({
    required int id,
    required List<int> itemIds,
  }) =>
      currentUserBooruRepository
          .get()
          .then((userBooru) => api.patchFavoriteGroups(
                userBooru?.login,
                userBooru?.apiKey,
                id,
                postIdsString: itemIds.join(' '),
              ))
          .then((value) {
        return [302, 204].contains(value.response.statusCode);
      });

  @override
  Future<bool> editFavoriteGroup({
    required int id,
    String? name,
    List<int>? itemIds,
    bool isPrivate = false,
  }) async {
    try {
      return await currentUserBooruRepository
          .get()
          .then((userBooru) => api.patchFavoriteGroups(
                userBooru?.login,
                userBooru?.apiKey,
                id,
                name: name,
                isPrivate: isPrivate,
                postIdsString: itemIds?.join(' '),
              ))
          .then((value) => true);
    } on DioError catch (e, stackTrace) {
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
