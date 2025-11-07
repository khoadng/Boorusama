// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/router.dart';
import '../../favgroups/types.dart';

void goToFavoriteGroupDetailsPage(
  WidgetRef ref,
  DanbooruFavoriteGroup group,
) {
  ref.router.push(
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
