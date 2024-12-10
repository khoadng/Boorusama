// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../router.dart';
import '../types/danbooru_upload_post.dart';

void goToTagEditUploadPage(
  BuildContext context, {
  required DanbooruUploadPost post,
  required int uploadId,
}) {
  context.push(
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

void goToMyUploadsPage(BuildContext context) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'uploads',
      ],
    ).toString(),
  );
}
