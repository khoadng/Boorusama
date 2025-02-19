// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../../../../../../core/router.dart';

void goToExplorePage(BuildContext context) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'explore',
      ],
    ).toString(),
  );
}

void goToExplorePopularPage(BuildContext context) {
  context.push(
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

void goToExploreHotPage(BuildContext context) {
  context.push(
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

void goToExploreMostViewedPage(BuildContext context) {
  context.push(
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
