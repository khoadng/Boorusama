// Project imports:
import 'package:boorusama/core/posts/post/post.dart';
import 'danbooru_post.dart';

mixin DanbooruPostRepositoryMixin {
  PostRepository<DanbooruPost> get postRepository;

  Future<PostResult<DanbooruPost>> getPostsOrEmpty(String tags, int page) =>
      postRepository.getPosts(tags, page).run().then((value) => value.fold(
            (l) => <DanbooruPost>[].toResult(),
            (r) => r,
          ));
}

extension DanbooruRepoX on PostRepository<DanbooruPost> {
  PostsOrError<DanbooruPost> getPostsFromIds(List<int> ids) => getPosts(
        'id:${ids.join(',')}',
        1,
        limit: ids.length,
      );
}
