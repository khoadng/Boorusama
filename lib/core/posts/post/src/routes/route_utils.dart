// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/toast.dart';
import '../../../../images/booru_image.dart';
import '../../../../router.dart';
import '../pages/quick_preview_image_dialog.dart';
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

void goToImagePreviewPage(WidgetRef ref, BuildContext context, Post post) {
  showGeneralDialog(
    context: context,
    routeSettings: const RouteSettings(
      name: RouterPageConstant.postQuickPreview,
    ),
    pageBuilder: (context, animation, secondaryAnimation) =>
        QuickPreviewImageDialog(
      child: BooruImage(
        placeholderUrl: post.thumbnailImageUrl,
        aspectRatio: post.aspectRatio,
        imageUrl: post.sampleImageUrl,
      ),
    ),
  );
}
