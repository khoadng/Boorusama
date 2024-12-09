// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/foundation/animations.dart';
import 'package:boorusama/foundation/display.dart';
import '../../../post/post.dart';
import 'danbooru_favorite_group.dart';
import 'pages/add_to_favorite_group_page.dart';
import 'pages/create_favorite_group_dialog.dart';

Future<bool?> goToAddToFavoriteGroupSelectionPage(
  BuildContext context,
  List<DanbooruPost> posts,
) {
  return showMaterialModalBottomSheet<bool>(
    context: context,
    duration: AppDurations.bottomSheet,
    expand: true,
    builder: (_) => AddToFavoriteGroupPage(
      posts: posts,
    ),
  );
}

Future<Object?> goToFavoriteGroupCreatePage(
  BuildContext context, {
  bool enableManualPostInput = true,
}) {
  return showGeneralDialog(
    context: context,
    pageBuilder: (___, _, __) => EditFavoriteGroupDialog(
      padding: kPreferredLayout.isMobile ? 0 : 8,
      title: 'favorite_groups.create_group'.tr(),
      enableManualDataInput: enableManualPostInput,
    ),
  );
}

Future<Object?> goToFavoriteGroupEditPage(
  BuildContext context,
  DanbooruFavoriteGroup group,
) {
  return showGeneralDialog(
    context: context,
    pageBuilder: (dialogContext, _, __) => EditFavoriteGroupDialog(
      initialData: group,
      padding: kPreferredLayout.isMobile ? 0 : 8,
      title: 'favorite_groups.edit_group'.tr(),
    ),
  );
}
