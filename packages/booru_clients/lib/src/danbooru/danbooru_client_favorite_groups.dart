// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

const _kFavoriteGroupParams =
    'id,name,post_ids,created_at,updated_at,is_public,creator';

mixin DanbooruClientFavoriteGroups {
  Dio get dio;

  Future<List<FavoriteGroupDto>> getFavoriteGroups({
    int? page,
    required String creatorName,
    int? limit,
  }) async {
    final response = await dio.get(
      '/favorite_groups.json',
      queryParameters: {
        if (page != null) 'page': page,
        'search[creator_name]': creatorName,
        'only': _kFavoriteGroupParams,
        if (limit != null) 'limit': limit,
      },
    );

    return (response.data as List)
        .map((item) => FavoriteGroupDto.fromJson(item))
        .toList();
  }

  Future<FavoriteGroupDto> postFavoriteGroups({
    required String name,
    required List<int> postIds,
    bool? isPrivate,
  }) async {
    final formData = {
      'favorite_group[name]': name,
      'favorite_group[post_ids_string]': postIds.join(' '),
      'favorite_group[is_private]': isPrivate,
    };

    final response = await dio.post(
      '/favorite_groups.json',
      data: formData,
      options: Options(
        headers: dio.options.headers,
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    return FavoriteGroupDto.fromJson(response.data);
  }

  Future<void> patchFavoriteGroups({
    required int groupId,
    String? name,
    List<int>? postIds,
    bool? isPrivate,
  }) async {
    final formData = {
      if (name != null) 'favorite_group[name]': name,
      if (postIds != null) 'favorite_group[post_ids_string]': postIds.join(' '),
      if (isPrivate != null) 'favorite_group[is_private]': isPrivate,
    };

    final _ = await dio.patch(
      '/favorite_groups/$groupId.json',
      data: formData,
      options: Options(
        headers: dio.options.headers,
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
  }

  Future<void> deleteFavoriteGroup({
    int? groupId,
  }) async {
    final _ = await dio.delete(
      '/favorite_groups/$groupId.json',
    );
  }
}
