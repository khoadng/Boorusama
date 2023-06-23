// Package imports:
import 'package:riverpod_infinite_scroll/riverpod_infinite_scroll.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/forums/forums.dart';
import 'package:boorusama/boorus/danbooru/feats/forums/posts/danbooru_forum_post_repository.dart';

class DanbooruForumPostsNotifier extends PagedNotifier<int, DanbooruForumPost> {
  DanbooruForumPostsNotifier({
    required int topicId,
    required DanbooruForumPostRepository repo,
  }) : super(
          load: (key, limit) => repo.getForumPostsOrEmpty(topicId, key),
          nextPageKeyBuilder: NextPageKeyBuilderDefault.mysqlPagination,
        );
}
