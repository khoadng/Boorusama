// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/router.dart';
import '../../types.dart';

void goToSzurubooruPoolPage(WidgetRef ref) {
  ref.router.push('/szurubooru/pools');
}

void goToSzurubooruPoolSearchPage(WidgetRef ref) {
  ref.router.push('/szurubooru/pools/search');
}

void goToSzurubooruPoolDetailPage(WidgetRef ref, SzurubooruPool pool) {
  ref.router.push(
    Uri(
      pathSegments: [
        '',
        'szurubooru',
        'pools',
        '${pool.id}',
      ],
    ).toString(),
    extra: pool,
  );
}
