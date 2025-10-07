// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/router.dart';
import '../types/dmail_id.dart';

void goToDmailPage(
  WidgetRef ref, {
  DmailFolderType? folder,
}) {
  ref.router.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'dmails',
      ],
      queryParameters: folder != null ? {'folder': folder.name} : null,
    ).toString(),
  );
}

void goToDmailDetailsPage(
  WidgetRef ref, {
  required DmailId dmailId,
}) {
  ref.router.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'dmails',
        dmailId.toPathSegment(),
      ],
    ).toString(),
  );
}
