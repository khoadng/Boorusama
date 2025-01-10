// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/foundation/display.dart';
import '../../../../../core/router.dart';
import '../../../../../core/tags/tag/tag.dart';
import 'danbooru_show_tag_list_page.dart';

Future<bool?> goToDanbooruShowTaglistPage(
  WidgetRef ref,
  List<Tag> tags,
) {
  return showAdaptiveSheet(
    navigatorKey.currentContext ?? ref.context,
    expand: true,
    settings: const RouteSettings(
      name: 'view_tag_list',
    ),
    builder: (context) => DanbooruShowTagListPage(
      tags: tags,
    ),
  );
}
