// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../../../../../../../router.dart';

void goToPoolSearchPage(BuildContext context) {
  context.push(
    Uri(
      path: '/danbooru/pools/search',
    ).toString(),
  );
}
