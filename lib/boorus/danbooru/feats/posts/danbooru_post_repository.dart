// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'danbooru_post.dart';

typedef DanbooruPostsOrError = PostsOrErrorCore<DanbooruPost>;

mixin DanbooruPostRepositoryMixin {
  PostRepository<DanbooruPost> get postRepository;

  Future<List<DanbooruPost>> getPostsOrEmpty(String tags, int page) =>
      postRepository
          .getPostsFromTags(tags, page)
          .run()
          .then((value) => value.fold(
                (l) => <DanbooruPost>[],
                (r) => r,
              ));
}

extension DanbooruRepoX on PostRepository<DanbooruPost> {
  PostsOrError<DanbooruPost> getPostsFromIds(List<int> ids) => getPostsFromTags(
        'id:${ids.join(',')}',
        1,
        limit: ids.length,
      );
}
