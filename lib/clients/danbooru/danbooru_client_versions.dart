// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/clients/danbooru/types/post_version_dto.dart';

const kPostVersionParams =
    'id,post_id,tags,added_tags,removed_tags,updater_id,updated_at,rating,rating_changed,parent_id,parent_changed,source,source_changed,version,obsolete_added_tags,obsolete_removed_tags,unchanged_tags,updater';

mixin DanbooruClientVersions {
  Dio get dio;

  Future<List<PostVersionDto>> getPostVersions({
    required int id,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get(
      '/post_versions.json',
      cancelToken: cancelToken,
      queryParameters: {
        'search[post_id]': id,
        'only': kPostVersionParams,
      },
    );

    return (response.data as List)
        .map((item) => PostVersionDto.fromJson(item))
        .toList();
  }
}
