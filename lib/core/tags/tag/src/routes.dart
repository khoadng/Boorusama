// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../foundation/display.dart';
import '../../../router.dart';
import 'pages/default_show_tag_list_page.dart';
import 'tag.dart';

Future<bool?> goToShowTaglistPage(
  BuildContext context,
  List<Tag> tags,
) {
  return showAdaptiveSheet(
    navigatorKey.currentContext ?? context,
    expand: true,
    settings: const RouteSettings(
      name: 'view_tag_list',
    ),
    builder: (context) => DefaultShowTagListPage(
      tags: tags,
    ),
  );
}
