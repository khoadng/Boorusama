// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../../../../../../core/router.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../../../../foundation/display.dart';
import '../pages/user_feedback_page.dart';

final danbooruUserFeedbackRoutes = GoRoute(
  path: '/danbooru/user_feedbacks',
  name: 'user_feedbacks',
  pageBuilder: largeScreenAwarePageBuilder(
    useDialog: true,
    builder: (context, state) {
      final userId = int.tryParse(
        state.uri.queryParameters['search[user_id]'] ?? '',
      );

      final landscape = context.orientation.isLandscape;

      if (userId == null) {
        return const BooruDialog(
          padding: EdgeInsets.all(8),
          child: InvalidPage(
            message: 'Invalid user ID',
          ),
        );
      }

      final page = UserFeedbackPage(userId: userId);

      return landscape
          ? BooruDialog(
              padding: const EdgeInsets.all(8),
              child: page,
            )
          : page;
    },
  ),
);
