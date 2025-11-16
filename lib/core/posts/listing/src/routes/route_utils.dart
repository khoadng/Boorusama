// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../../../../configs/config/types.dart';
import '../../../post/types.dart';
import '../pages/quick_preview_image_dialog.dart';

void goToImagePreviewPage(
  BuildContext context,
  Post post,
  BooruConfigAuth config,
) {
  showGeneralDialog(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) =>
        QuickPreviewImageDialog(
          post: post,
          config: config,
        ),
  );
}
