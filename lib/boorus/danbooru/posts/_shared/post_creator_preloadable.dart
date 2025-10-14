// Project imports:
import '../post/types.dart';

class PostCreatorsPreloadable {
  factory PostCreatorsPreloadable.fromPosts(List<DanbooruPost> posts) {
    final ids = posts
        .map(
          (e) => [
            e.uploaderId,
            if (e.approverId != null) e.approverId!,
          ],
        )
        .expand((e) => e)
        .toSet()
        .toList();

    return PostCreatorsPreloadable._(ids);
  }
  PostCreatorsPreloadable._(this.userIds);

  final List<int> userIds;
}
