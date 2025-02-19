// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../../../../../../../core/router.dart';

void goToFavoriteGroupPage(BuildContext context) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'favorite_groups',
      ],
    ).toString(),
  );
}
