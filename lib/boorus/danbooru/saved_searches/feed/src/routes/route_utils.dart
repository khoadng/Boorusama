// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../../../../../../core/router.dart';

void goToSavedSearchPage(BuildContext context) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'internal',
        'danbooru',
        'saved_searches',
        'feed',
      ],
    ).toString(),
  );
}
