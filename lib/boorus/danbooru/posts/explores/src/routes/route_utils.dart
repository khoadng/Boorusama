// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/router.dart';

void goToExplorePage(WidgetRef ref) {
  ref.router.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'explore',
      ],
    ).toString(),
  );
}

void goToExplorePopularPage(WidgetRef ref) {
  ref.router.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'explore',
        'posts',
        'popular',
      ],
    ).toString(),
  );
}

void goToExploreHotPage(WidgetRef ref) {
  ref.router.push(
    Uri(
      pathSegments: [
        '',
        'internal',
        'danbooru',
        'explore',
        'posts',
        'hot',
      ],
    ).toString(),
  );
}

void goToExploreMostViewedPage(WidgetRef ref) {
  ref.router.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'explore',
        'posts',
        'viewed',
      ],
    ).toString(),
  );
}
