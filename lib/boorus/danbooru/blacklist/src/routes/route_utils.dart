// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:boorusama/router.dart';

void goToBlacklistedTagPage(BuildContext context) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'internal',
        'danbooru',
        'settings',
        'blacklist',
      ],
    ).toString(),
  );
}
