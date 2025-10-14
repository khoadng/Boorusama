// Project imports:
import '../../../../../core/posts/post/types.dart';
import 'danbooru_post.dart';

extension DanbooruRepoX on PostRepository<DanbooruPost> {
  PostsOrError<DanbooruPost> getPostsFromIds(List<int> ids) => getPosts(
    'id:${ids.join(',')}',
    1,
    limit: ids.length,
  );
}
