// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/router.dart';

void goToPoolPage(WidgetRef ref) {
  ref.router.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'pools',
      ],
    ).toString(),
  );
}
