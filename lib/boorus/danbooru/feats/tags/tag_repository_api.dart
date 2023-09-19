// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'package:boorusama/clients/danbooru/types/types.dart';

class TagRepositoryApi implements TagRepository {
  TagRepositoryApi(
    this.client,
  );

  final DanbooruClient client;

  @override
  Future<List<Tag>> getTagsByName(
    List<String> tags,
    int page, {
    CancelToken? cancelToken,
  }) async {
    try {
      return client
          .getTagsByName(
            page: page,
            hideEmpty: true,
            tags: tags,
            cancelToken: cancelToken,
          )
          .then((dtos) => dtos.map(tagDtoToTag).toList());
    } on DioException catch (e, stackTrace) {
      if (e.type == DioExceptionType.cancel) {
        // Cancel token triggered, skip this request
        return [];
      } else {
        Error.throwWithStackTrace(
          Exception('Failed to get posts for ${tags.join(',')}}'),
          stackTrace,
        );
      }
    }
  }
}

Tag tagDtoToTag(TagDto d) => Tag(
      name: d.name ?? '',
      category: intToTagCategory(d.category ?? 0),
      postCount: d.postCount ?? 0,
    );
