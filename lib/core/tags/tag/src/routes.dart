// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../router.dart';
import '../../../foundation/display.dart';
import 'pages/show_tag_list_page.dart';
import 'tag.dart';

Future<bool?> goToShowTaglistPage(
  BuildContext context,
  List<Tag> tags,
) {
  return showAdaptiveSheet(
    navigatorKey.currentContext ?? context,
    expand: true,
    builder: (context) => DefaultShowTagListPage(
      tags: tags,
    ),
  );
}
