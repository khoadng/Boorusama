// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../../../core/foundation/display.dart';
import '../../../../post/post.dart';
import '../pages/add_to_favorite_group_page.dart';
import '../pages/create_favorite_group_dialog.dart';
import '../types/danbooru_favorite_group.dart';

Future<bool?> goToAddToFavoriteGroupSelectionPage(
  BuildContext context,
  List<DanbooruPost> posts,
) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    routeSettings: const RouteSettings(
      name: 'add_to_favorite_group',
    ),
    useSafeArea: true,
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
    routeSettings: const RouteSettings(
      name: 'favorite_group_create',
    ),
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
    routeSettings: const RouteSettings(
      name: 'favorite_group_edit',
    ),
    pageBuilder: (dialogContext, _, __) => EditFavoriteGroupDialog(
      initialData: group,
      padding: kPreferredLayout.isMobile ? 0 : 8,
      title: 'favorite_groups.edit_group'.tr(),
    ),
  );
}
