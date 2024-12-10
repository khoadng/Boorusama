// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:boorusama/router.dart';
import '../types/dmail.dart';

void goToDmailPage(BuildContext context) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'dmails',
      ],
    ).toString(),
  );
}

void goToDmailDetailsPage(
  BuildContext context, {
  required Dmail dmail,
}) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'dmails',
        '${dmail.id}',
      ],
    ).toString(),
    extra: dmail,
  );
}
