// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/router.dart';
import '../types/danbooru_upload_post.dart';

void goToTagEditUploadPage(
  WidgetRef ref, {
  required DanbooruUploadPost post,
  required int uploadId,
}) {
  ref.router.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'uploads',
        '$uploadId',
      ],
    ).toString(),
    extra: post,
  );
}

void goToMyUploadsPage(WidgetRef ref) {
  ref.router.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'uploads',
      ],
    ).toString(),
  );
}
