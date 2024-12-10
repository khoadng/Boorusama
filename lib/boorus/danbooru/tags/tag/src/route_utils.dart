// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/tags/tag/tag.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/router.dart';
import 'danbooru_show_tag_list_page.dart';

Future<bool?> goToDanbooruShowTaglistPage(
  WidgetRef ref,
  List<Tag> tags,
) {
  return showAdaptiveSheet(
    navigatorKey.currentContext ?? ref.context,
    expand: true,
    builder: (context) => DanbooruShowTagListPage(
      tags: tags,
    ),
  );
}
