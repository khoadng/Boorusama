// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../../../../../core/router.dart';
import '../../../posts/post/post.dart';

void goToPostVersionPage(BuildContext context, DanbooruPost post) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'post_versions',
      ],
      queryParameters: {
        'search[post_id]': post.id.toString(),
      },
    ).toString(),
    extra: post,
  );
}
