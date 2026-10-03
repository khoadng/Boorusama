// Project imports:
import 'package:boorusama/core/posts/post/types.dart';
import 'package:boorusama/core/posts/rating/types.dart';
import 'package:boorusama/core/posts/sources/types.dart';

final class TestPost extends SimplePost {
  TestPost({
    required super.id,
    super.tags = const {},
    PostSource? source,
    super.thumbnailImageUrl = '',
    super.sampleImageUrl = '',
    super.originalImageUrl = '',
    super.md5 = '',
    super.width = 100,
    super.height = 100,
    super.fileSize = 1024,
    super.format = '.jpg',
  }) : super(
         rating: Rating.general,
         hasComment: false,
         isTranslated: false,
         hasParentOrChildren: false,
         source: source ?? PostSource.none(),
         score: 10,
         duration: kNoduration,
         hasSound: null,
         videoThumbnailUrl: '',
         videoUrl: '',
         uploaderId: null,
         metadata: null,
         createdAt: null,
         parentId: null,
         downvotes: null,
         uploaderName: null,
       );
}

/// Posts with consecutive IDs from [first] to [last], both inclusive.
List<TestPost> testPostRange(int first, int last) => [
  for (var id = first; id <= last; id++) TestPost(id: id),
];

PostResult<Post> testPostResult(List<Post> posts, {int maxPage = 1}) =>
    PostResult<Post>(
      posts: List<Post>.unmodifiable(posts),
      total: posts.length,
      maxPage: maxPage,
    );
