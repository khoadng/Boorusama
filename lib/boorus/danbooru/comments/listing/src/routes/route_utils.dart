// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../../../../../../router.dart';

void goToCommentCreatePage(
  BuildContext context, {
  required int postId,
  String? initialContent,
}) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'internal',
        'danbooru',
        'posts',
        '$postId',
        'comments',
        'editor',
      ],
      queryParameters: {
        if (initialContent != null) 'text': initialContent,
      },
    ).toString(),
  );
}

void goToCommentUpdatePage(
  BuildContext context, {
  required int postId,
  required int commentId,
  required String commentBody,
}) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'internal',
        'danbooru',
        'posts',
        '$postId',
        'comments',
        'editor',
      ],
      queryParameters: {
        'text': commentBody,
        'comment_id': commentId.toString(),
      },
    ).toString(),
  );
}
