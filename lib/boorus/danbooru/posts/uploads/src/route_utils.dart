// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/router.dart';
import 'danbooru_upload_post.dart';

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
