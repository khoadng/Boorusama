// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:boorusama/router.dart';
import '../../favgroups/favgroup.dart';

void goToFavoriteGroupDetailsPage(
  BuildContext context,
  DanbooruFavoriteGroup group,
) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'favorite_groups',
        '${group.id}',
      ],
    ).toString(),
    extra: group,
  );
}
