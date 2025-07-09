// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/router.dart';
import '../../../topics/topic.dart';

void goToForumPostsPage(
  WidgetRef ref, {
  required DanbooruForumTopic topic,
}) {
  ref.router.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'forum_topics',
        '${topic.id}',
      ],
    ).toString(),
    extra: topic,
  );
}
