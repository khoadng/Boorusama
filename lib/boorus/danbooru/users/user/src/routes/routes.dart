// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../../../../../../core/router.dart';
import '../pages/danbooru_favoriter_list_page.dart';
import '../pages/danbooru_voter_list_page.dart';

final danbooruFavoriterListRoutes = GoRoute(
  path: '/internal/danbooru/posts/:id/favoriter',
  pageBuilder: (context, state) => CupertinoPage(
    key: state.pageKey,
    name: state.name,
    child: Builder(
      builder: (context) {
        final postId = int.tryParse(state.pathParameters['id'] ?? '');

        if (postId == null) {
          return const InvalidPage(
            message: 'Invalid post ID',
          );
        }

        return DanbooruFavoriterListPage(postId: postId);
      },
    ),
  ),
);

final danbooruVoterListRoutes = GoRoute(
  path: '/internal/danbooru/posts/:id/voter',
  pageBuilder: (context, state) => CupertinoPage(
    key: state.pageKey,
    name: state.name,
    child: Builder(
      builder: (context) {
        final postId = int.tryParse(state.pathParameters['id'] ?? '');

        if (postId == null) {
          return const InvalidPage(
            message: 'Invalid post ID',
          );
        }

        return DanbooruVoterListPage(postId: postId);
      },
    ),
  ),
);
