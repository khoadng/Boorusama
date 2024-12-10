// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/foundation/display.dart';
import '../../../../../core/tags/tag/tag.dart';
import '../../../../../router.dart';
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
