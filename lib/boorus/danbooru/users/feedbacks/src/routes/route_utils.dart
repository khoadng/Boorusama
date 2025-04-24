// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../../../../../../core/router.dart';

void goToUserFeedbackPage(BuildContext context, int userId) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'user_feedbacks',
      ],
      queryParameters: {
        'search[user_id]': userId.toString(),
      },
    ).toString(),
  );
}
