// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/router.dart';

Future<String?> goToCommentCreatePage(
  WidgetRef ref, {
  required int postId,
  String? initialContent,
}) {
  return ref.router.push<String>(
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
        'text': ?initialContent,
      },
    ).toString(),
  );
}

Future<String?> goToCommentUpdatePage(
  WidgetRef ref, {
  required int postId,
  required int commentId,
  required String commentBody,
}) {
  return ref.router.push<String>(
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
