// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import '../pages/quick_edit_details_config_page.dart';

void goToQuickEditPostDetailsLayoutPage(
  BuildContext context,
) {
  Navigator.of(context).push(
    CupertinoPageRoute(
      builder: (context) => const QuickEditDetailsConfigPage(),
    ),
  );
}
