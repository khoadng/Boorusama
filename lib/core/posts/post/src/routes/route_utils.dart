// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../foundation/toast.dart';
import '../../../../configs/config/providers.dart';
import '../../../../images/booru_image.dart';
import '../../../../router.dart';
import '../../post.dart';
import '../pages/quick_preview_image_dialog.dart';

void goToOriginalImagePage(
  WidgetRef ref,
  Post post, {
  required VideoInfoExtractor videoInfoExtractor,
}) {
  final isMp4 = videoInfoExtractor.extract(post).isMp4;
  if (isMp4) {
    showSimpleSnackBar(
      context: ref.context,
      content: Text('This is a video post, cannot view original image'.hc),
    );
    return;
  }

  ref.router.push(
    Uri(
      path: '/original_image_viewer',
    ).toString(),
    extra: post,
  );
}

void goToImagePreviewPage(BuildContext context, Post post) {
  showGeneralDialog(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) =>
        QuickPreviewImageDialog(
          child: Consumer(
            builder: (_, ref, _) => BooruImage(
              config: ref.watchConfigAuth,
              fit: BoxFit.contain,
              imageUrl: post.isVideo
                  ? post.videoThumbnailUrl
                  : post.sampleImageUrl,
              placeholderUrl: post.thumbnailImageUrl,
            ),
          ),
        ),
  );
}
