// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/router.dart';
import '../../../pool/types.dart';

void goToPoolDetailPage(WidgetRef ref, DanbooruPool pool) {
  ref.router.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'pools',
        '${pool.id}',
      ],
    ).toString(),
    extra: pool,
  );
}
