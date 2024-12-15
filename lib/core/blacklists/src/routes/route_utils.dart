// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../../../router.dart';

void goToGlobalBlacklistedTagsPage(BuildContext context) {
  context.push(
    Uri(
      path: '/global_blacklisted_tags',
    ).toString(),
  );
}
