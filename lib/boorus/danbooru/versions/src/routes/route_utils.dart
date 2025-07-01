// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/router.dart';
import '../../../posts/post/post.dart';

void goToPostVersionPage(WidgetRef ref, DanbooruPost post) {
  ref.router.push(
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
