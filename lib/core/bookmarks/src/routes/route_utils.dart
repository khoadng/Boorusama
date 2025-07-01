// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../posts/listing/providers.dart';
import '../../../router.dart';
import '../data/bookmark_convert.dart';

Future<void> goToBookmarkPage(
  WidgetRef ref,
) {
  return ref.router.push(
    Uri(
      path: '/bookmarks',
    ).toString(),
  );
}

Future<void> goToBookmarkDetailsPage(
  WidgetRef ref,
  int index, {
  required String initialThumbnailUrl,
  required PostGridController<BookmarkPost> controller,
}) {
  return ref.router.push(
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
