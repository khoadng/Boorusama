// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../../../../../../core/router.dart';
import '../pages/danbooru_profile_page.dart';
import '../pages/user_details_page.dart';

final danbooruProfileRoutes = GoRoute(
  path: '/danbooru/profile',
  pageBuilder: (context, state) => CupertinoPage(
    key: state.pageKey,
    name: state.name,
    child: const DanbooruProfilePage(),
  ),
);

final danbooruUserDetailsRoutes = GoRoute(
  path: '/danbooru/users/:id',
  pageBuilder: (context, state) => CupertinoPage(
    key: state.pageKey,
    name: state.name,
    child: Builder(
      builder: (context) {
        final userId = int.tryParse(state.pathParameters['id'] ?? '');

        if (userId == null) {
          return const InvalidPage(
            message: 'Invalid user ID',
          );
        }

        return UserDetailsPage(
          uid: userId,
        );
      },
    ),
  ),
);
