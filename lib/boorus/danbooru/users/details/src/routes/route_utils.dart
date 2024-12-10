// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:boorusama/router.dart';

void goToUserDetailsPage(
  BuildContext context, {
  required int uid,
}) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'users',
        '$uid',
      ],
    ).toString(),
  );
}

void goToProfilePage(BuildContext context) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'profile',
      ],
    ).toString(),
  );
}
