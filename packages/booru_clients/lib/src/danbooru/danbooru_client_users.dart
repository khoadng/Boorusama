// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

mixin DanbooruClientUsers {
  Dio get dio;

  Future<List<UserDto>> getUsersByIds({
    required List<int> ids,
    int? limit,
    CancelToken? cancelToken,
  }) async {
    if (ids.isEmpty) return [];

    final response = await dio.get(
      '/users.json',
      queryParameters: {
        'search[id]': ids.join(','),
        if (limit != null) 'limit': limit,
      },
      cancelToken: cancelToken,
    );

    return (response.data as List)
        .map((item) => UserDto.fromJson(item))
        .toList();
  }

  Future<UserDto> getUserById({
    required int id,
  }) async {
    final response = await dio.get(
      '/users/$id.json',
    );

    return UserDto.fromJson(response.data);
  }

  Future<UserSelfDto> getUserSelfById({
    required int id,
  }) async {
    final response = await dio.get(
      '/users/$id.json',
    );

    return UserSelfDto.fromJson(response.data);
  }

  Future<void> setBlacklistedTags({
    required int id,
    required List<String> blacklistedTags,
    CancelToken? cancelToken,
  }) async {
    final _ = await dio.patch(
      '/users/$id.json',
      data: {
        'user[blacklisted_tags]': blacklistedTags.join('\n'),
      },
      options: Options(
        headers: dio.options.headers,
        contentType: 'application/x-www-form-urlencoded',
      ),
      cancelToken: cancelToken,
    );
  }
}
