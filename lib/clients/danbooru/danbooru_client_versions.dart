// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/clients/danbooru/types/post_version_dto.dart';

const kPostVersionParams =
    'id,post_id,tags,added_tags,removed_tags,updater_id,updated_at,rating,rating_changed,parent_id,parent_changed,source,source_changed,version,obsolete_added_tags,obsolete_removed_tags,unchanged_tags,updater';

mixin DanbooruClientVersions {
  Dio get dio;

  Future<List<PostVersionDto>> getPostVersions({
    int? id,
    String? updaterName,
    List<String>? addedTags,
    List<String>? removedTags,
    List<String>? changedTags,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get(
      '/post_versions.json',
      cancelToken: cancelToken,
      queryParameters: {
        if (id != null) 'search[post_id]': id,
        'search[post_id]': id,
        if (updaterName != null) 'search[updater_name]': updaterName,
        if (addedTags != null && addedTags.isNotEmpty)
          'search[added_tags_include_all]': addedTags.join(' '),
        if (removedTags != null && removedTags.isNotEmpty)
          'search[removed_tags_include_all]': removedTags.join(' '),
        if (changedTags != null && changedTags.isNotEmpty)
          'search[changed_tags]': changedTags.join(' '),
        'only': kPostVersionParams,
      },
    );

    return (response.data as List)
        .map((item) => PostVersionDto.fromJson(item))
        .toList();
  }
}
