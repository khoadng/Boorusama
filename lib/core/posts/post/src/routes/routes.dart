// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../../../../router.dart';
import '../../../../widgets/route_transition_builder.dart';
import '../pages/original_image_page.dart';
import '../types/post.dart';

final originalImageRoutes = GoRoute(
  path: 'original_image_viewer',
  name: '/original_image_viewer',
  pageBuilder: (context, state) {
    final post = state.extra as Post?;

    if (post == null) {
      return const CupertinoPage(
        child: InvalidPage(message: 'Invalid post'),
      );
    }

    return CustomTransitionPage(
      key: state.pageKey,
      name: state.name,
      transitionsBuilder: fadeTransitionBuilder(),
      child: OriginalImagePage.post(post),
    );
  },
);
