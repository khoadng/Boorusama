// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../../../../../../router.dart';

void goToArtistSearchPage(BuildContext context) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'artists',
      ],
    ).toString(),
  );
}
