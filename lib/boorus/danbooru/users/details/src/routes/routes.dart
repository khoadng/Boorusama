// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../../../../../../core/router.dart';
import '../pages/danbooru_profile_page.dart';
import '../pages/danbooru_user_details_page.dart';
import '../types/user_details.dart';

final danbooruProfileRoutes = GoRoute(
  path: '/danbooru/profile',
  name: 'profile',
  pageBuilder: (context, state) => CupertinoPage(
    key: state.pageKey,
    name: state.name,
    child: const DanbooruProfilePage(),
  ),
);

final danbooruUserDetailsRoutes = GoRoute(
  path: '/danbooru/users/:id',
  name: 'user_details',
  pageBuilder: (context, state) => CupertinoPage(
    key: state.pageKey,
    name: state.name,
    child: Builder(
      builder: (context) {
        final details = UserDetails.fromParams(
          queryParameters: state.uri.queryParameters,
          pathParameters: state.pathParameters,
        );

        if (details == null) {
          return const InvalidPage(
            message: 'Invalid user',
          );
        }

        return DanbooruUserDetailsPage(
          details: details,
        );
      },
    ),
  ),
);
