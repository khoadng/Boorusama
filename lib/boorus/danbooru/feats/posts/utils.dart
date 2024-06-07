// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/tags/tag_filter_category.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/functional.dart';

String generateFullReadableName(DanbooruPost post) =>
    '${generateCharacterOnlyReadableName(post.characterTags)} (${generateCopyrightOnlyReadableName(post.copyrightTags)}) drawn by ${post.artistTags.join(' ')}';

mixin DanbooruPostRepositoryMixin {
  PostRepository<DanbooruPost> get postRepository;

  Future<List<DanbooruPost>> getPostsOrEmpty(String tags, int page) =>
      postRepository.getPosts(tags, page).run().then((value) => value.fold(
            (l) => <DanbooruPost>[],
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
