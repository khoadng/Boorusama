// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../../../../../../../core/router.dart';

void goToPoolPage(BuildContext context) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'pools',
      ],
    ).toString(),
  );
}
