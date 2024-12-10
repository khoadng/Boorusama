// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../../../../../../router.dart';
import '../../../../posts/post/post.dart';

void goToTagEditPage(
  BuildContext context, {
  required DanbooruPost post,
}) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'internal',
        'danbooru',
        'posts',
        '${post.id}',
        'editor',
      ],
    ).toString(),
    extra: post,
  );
}
