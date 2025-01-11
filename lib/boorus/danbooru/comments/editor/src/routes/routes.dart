// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../../../../../../core/router.dart';
import '../pages/comment_create_page.dart';
import '../pages/comment_update_page.dart';

final danbooruCommentEditorRoutes = GoRoute(
  path: '/internal/danbooru/posts/:id/comments/editor',
  name: 'comments/editor',
  pageBuilder: (context, state) => CupertinoPage(
    key: state.pageKey,
    name: state.name,
    child: Builder(
      builder: (context) {
        final postId = int.tryParse(state.pathParameters['id'] ?? '');
        final text = state.uri.queryParameters['text'];
        final commentId =
            int.tryParse(state.uri.queryParameters['comment_id'] ?? '');

        if (postId == null) {
          return const InvalidPage(
            message: 'Invalid post ID',
          );
        }

        if (commentId != null && text != null) {
          return CommentUpdatePage(
            postId: postId,
            commentId: commentId,
            initialContent: text,
          );
        } else {
          return CommentCreatePage(
            postId: postId,
            initialContent: text,
          );
        }
      },
    ),
  ),
);
