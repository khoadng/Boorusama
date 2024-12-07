// Project imports:
import '../post/danbooru_post.dart';

class PostCreatorsPreloadable {
  PostCreatorsPreloadable._(this.userIds);

  final List<int> userIds;

  factory PostCreatorsPreloadable.fromPosts(List<DanbooruPost> posts) {
    final ids = posts
        .map((e) => [
              e.uploaderId,
              if (e.approverId != null) e.approverId!,
            ])
        .expand((e) => e)
        .toSet()
        .toList();

    return PostCreatorsPreloadable._(ids);
  }
}
