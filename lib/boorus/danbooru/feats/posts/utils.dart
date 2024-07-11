// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/functional.dart';

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

Option<String> tagFilterCategoryToString(TagFilterCategory category) =>
    category == TagFilterCategory.popular ? const Some('order:score') : none();
