// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../../../../../../router.dart';
import '../../../topics/topic.dart';

void goToForumPostsPage(
  BuildContext context, {
  required DanbooruForumTopic topic,
}) {
  context.push(
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
