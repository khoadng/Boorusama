// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/domain/posts/post.dart';
import 'package:boorusama/core/infra/caching/cacher.dart';

class DanbooruArtistCharacterPostRepository implements DanbooruPostRepository {
  DanbooruArtistCharacterPostRepository({
    required this.danbooruPostRepository,
    required this.cache,
  });

  final DanbooruPostRepository danbooruPostRepository;
  final Cacher<String, List<DanbooruPost>> cache;

  @override
  Future<List<DanbooruPost>> getPosts(
    String tags,
    int page, {
    int? limit,
    bool? includeInvalid,
  }) async {
    final name = "$tags-$page-$limit-$includeInvalid";

    final item = cache.get(name);

    if (item != null) return item;

    final fresh = await danbooruPostRepository.getPosts(
      tags,
      page,
      limit: limit,
      includeInvalid: includeInvalid,
    );

    await cache.put(name, fresh);

    return fresh;
  }

  @override
  Future<List<DanbooruPost>> getPostsFromIds(List<int> ids) =>
      danbooruPostRepository.getPostsFromIds(ids);

  @override
  Future<List<Post>> getPostsFromTags(String tags, int page, {int? limit}) =>
      getPosts(tags, page, limit: limit);

  @override
  Future<bool> putTag(int postId, String tagString) =>
      danbooruPostRepository.putTag(postId, tagString);
}
