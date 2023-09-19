// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/clients/gelbooru/gelbooru_client.dart';
import 'package:boorusama/clients/gelbooru/types/types.dart';

class GelbooruTagRepositoryApi implements TagRepository {
  GelbooruTagRepositoryApi(this.client);

  final GelbooruClient client;

  @override
  Future<List<Tag>> getTagsByName(
    List<String> tags,
    int page, {
    CancelToken? cancelToken,
  }) {
    return client
        .getTags(
          tags: tags,
          page: page,
        )
        .then((value) => value.map(tagDtoToTag).toList());
  }
}

Tag tagDtoToTag(TagDto e) {
  return Tag(
    name: e.name ?? '',
    category: intToTagCategory(e.type ?? 0),
    postCount: e.count ?? 0,
  );
}
