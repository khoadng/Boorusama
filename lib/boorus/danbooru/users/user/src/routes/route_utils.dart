// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../../../../../../core/router.dart';
import '../../../../posts/post/post.dart';

void goToPostFavoritesDetails(BuildContext context, DanbooruPost post) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'internal',
        'danbooru',
        'posts',
        '${post.id}',
        'favoriter',
      ],
    ).toString(),
  );
}

void goToPostVotesDetails(BuildContext context, DanbooruPost post) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'internal',
        'danbooru',
        'posts',
        '${post.id}',
        'voter',
      ],
    ).toString(),
  );
}
