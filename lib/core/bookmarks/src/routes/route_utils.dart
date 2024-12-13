// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../../../router.dart';

Future<void> goToBookmarkPage(
  BuildContext context,
) async {
  context.push(
    Uri(
      path: '/bookmarks',
    ).toString(),
  );
}

Future<void> goToBookmarkDetailsPage(
  BuildContext context,
  int index,
) async {
  context.push(
    Uri(
      path: '/bookmarks/details',
      queryParameters: {
        'index': index.toString(),
      },
    ).toString(),
  );
}
