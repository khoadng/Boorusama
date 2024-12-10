// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:boorusama/router.dart';

void goToPoolSearchPage(BuildContext context) {
  context.push(
    Uri(
      path: '/danbooru/pools/search',
    ).toString(),
  );
}
