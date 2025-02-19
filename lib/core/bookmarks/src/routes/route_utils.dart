// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../../../router.dart';

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
}) {
  return context.push(
    Uri(
      path: '/bookmarks/details',
      queryParameters: {
        'index': index.toString(),
      },
    ).toString(),
    extra: initialThumbnailUrl,
  );
}
