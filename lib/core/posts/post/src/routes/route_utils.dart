// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../../../../foundation/toast.dart';
import '../../../../router.dart';
import '../types/post.dart';

void goToOriginalImagePage(BuildContext context, Post post) {
  if (post.isMp4) {
    showSimpleSnackBar(
      context: context,
      content: const Text('This is a video post, cannot view original image'),
    );
    return;
  }

  context.push(
    Uri(
      path: '/original_image_viewer',
    ).toString(),
    extra: post,
  );
}
