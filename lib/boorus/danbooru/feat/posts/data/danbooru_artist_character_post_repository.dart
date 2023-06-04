// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/foundation/caching/caching.dart';
import 'package:boorusama/functional.dart';
import '../models/danbooru_post.dart';
import '../models/danbooru_post_repository.dart';

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
  }) {
    final name = "$tags-$page-$limit";

    return cache.get(name).toOption().fold(
          () => repository
              .getPosts(
                tags,
                page,
                limit: limit,
              )
              .flatMap((r) => TaskEither(() async {
                    await cache.put(name, r);
                    return Either.of(r);
                  })),
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
