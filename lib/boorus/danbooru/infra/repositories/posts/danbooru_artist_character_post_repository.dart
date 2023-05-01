// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/infra/caching/cacher.dart';
import 'package:boorusama/functional.dart';

class DanbooruArtistCharacterPostRepository implements DanbooruPostRepository {
  DanbooruArtistCharacterPostRepository({
    required this.repository,
    required this.cache,
  });

  final DanbooruPostRepository repository;
  final Cacher<String, List<DanbooruPost>> cache;

  @override
  DanbooruPostsOrError getPosts(
    String tags,
    int page, {
    int? limit,
    bool? includeInvalid,
  }) {
    final name = "$tags-$page-$limit-$includeInvalid";

    return cache.get(name).toOption().fold(
          () => repository
              .getPosts(
            tags,
            page,
            limit: limit,
            includeInvalid: includeInvalid,
          )
              .map((data) {
            cache.put(name, data);
            return data;
          }),
          (data) => TaskEither.right(data),
        );
  }

  @override
  DanbooruPostsOrError getPostsFromIds(List<int> ids) =>
      repository.getPostsFromIds(ids);

  @override
  PostsOrError getPostsFromTags(String tags, int page, {int? limit}) =>
      getPosts(tags, page, limit: limit);
}
