// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../../../../../../../core/router.dart';

void goToPoolSearchPage(BuildContext context) {
  context.push(
    Uri(
      path: '/danbooru/pools/search',
    ).toString(),
  );
}
