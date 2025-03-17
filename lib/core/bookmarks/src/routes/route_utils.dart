// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../../../posts/listing/providers.dart';
import '../../../router.dart';
import '../data/bookmark_convert.dart';

Future<void> goToBookmarkPage(
  BuildContext context,
) {
  return context.push(
    Uri(
      path: '/bookmarks',
    ).toString(),
  );
}

Future<void> goToBookmarkDetailsPage(
  BuildContext context,
  int index, {
  required String initialThumbnailUrl,
  required PostGridController<BookmarkPost> controller,
}) {
  return context.push(
    Uri(
      path: '/bookmarks/details',
      queryParameters: {
        'index': index.toString(),
      },
    ).toString(),
    extra: {
      'controller': controller,
      'initialThumbnailUrl': initialThumbnailUrl,
    },
  );
}
