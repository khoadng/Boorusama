// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/router.dart';
import '../../pool/pool.dart';

void goToPoolDetailPage(BuildContext context, DanbooruPool pool) {
  context.push(
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
