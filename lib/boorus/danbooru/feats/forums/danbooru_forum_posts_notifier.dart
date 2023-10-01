// Package imports:
import 'package:riverpod_infinite_scroll/riverpod_infinite_scroll.dart';

// Project imports:
import 'package:boorusama/core/feats/forums/forums.dart';
import 'danbooru_forum_post.dart';

// Project imports:


class DanbooruForumPostsNotifier extends PagedNotifier<int, DanbooruForumPost> {
  DanbooruForumPostsNotifier({
    required int topicId,
    required ForumPostRepository<DanbooruForumPost> repo,
  }) : super(
          load: (key, limit) => repo.getForumPostsOrEmpty(topicId, page: key),
          nextPageKeyBuilder: (lastItems, page, limit) => (lastItems == null ||
                  lastItems.isEmpty ||
                  lastItems.length < limit)
              ? null
              : lastItems.last.id,
        );
}
