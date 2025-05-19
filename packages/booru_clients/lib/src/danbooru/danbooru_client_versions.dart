// Package imports:
import 'package:dio/dio.dart';

import 'types/post_version_dto.dart';

const kPostVersionParams =
    'id,post_id,tags,added_tags,removed_tags,updater_id,updated_at,rating,rating_changed,parent_id,parent_changed,source,source_changed,version,obsolete_added_tags,obsolete_removed_tags,unchanged_tags,updater';

mixin DanbooruClientVersions {
  Dio get dio;

  Future<List<PostVersionDto>> getPostVersions({
    int? id,
    String? updaterName,
    int? updaterId,
    List<String>? addedTags,
    List<String>? removedTags,
    List<String>? changedTags,
    CancelToken? cancelToken,
    bool? includePreview,
    int? page,
    int? limit,
  }) async {
    final effectivePage = _normalizePage(page);

    final response = await dio.get(
      '/post_versions.json',
      cancelToken: cancelToken,
      queryParameters: {
        if (effectivePage != null) 'page': page,
        if (limit != null) 'limit': limit,
        if (id != null) 'search[post_id]': id,
        if (updaterId != null) 'search[updater_id]': updaterId,
        if (updaterName != null) 'search[updater_name]': updaterName,
        if (addedTags != null && addedTags.isNotEmpty)
          'search[added_tags_include_all]': addedTags.join(' '),
        if (removedTags != null && removedTags.isNotEmpty)
          'search[removed_tags_include_all]': removedTags.join(' '),
        if (changedTags != null && changedTags.isNotEmpty)
          'search[changed_tags]': changedTags.join(' '),
        'only': _composeParams(
          includePreview: includePreview,
        ),
      },
    );

    return (response.data as List)
        .map((item) => PostVersionDto.fromJson(item))
        .toList();
  }
}

int? _normalizePage(int? page) {
  if (page == null || page < 1) return null;

  return page;
}

String _composeParams({
  bool? includePreview,
}) {
  return kPostVersionParams +
      (includePreview == true ? ',post[preview_file_url]' : '');
}
