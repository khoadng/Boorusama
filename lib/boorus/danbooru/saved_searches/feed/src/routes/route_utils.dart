// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/router.dart';

void goToSavedSearchPage(WidgetRef ref) {
  ref.router.push(
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
