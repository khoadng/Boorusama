// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/widgets/widgets.dart';
import '../../../../posts/post/types.dart';
import '../pages/add_to_favorite_group_page.dart';
import '../pages/create_favorite_group_sheet.dart';
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
  return showBooruModalBottomSheet(
    context: context,
    resizeToAvoidBottomInset: true,
    routeSettings: const RouteSettings(
      name: 'favorite_group_create',
    ),
    builder: (_) => EditFavoriteGroupSheet(
      title: context.t.favorite_groups.create_group,
      enableManualDataInput: enableManualPostInput,
    ),
  );
}

Future<Object?> goToFavoriteGroupEditPage(
  BuildContext context,
  DanbooruFavoriteGroup group,
) {
  return showBooruModalBottomSheet(
    context: context,
    resizeToAvoidBottomInset: true,
    routeSettings: const RouteSettings(
      name: 'favorite_group_edit',
    ),
    builder: (_) => EditFavoriteGroupSheet(
      initialData: group,
      title: context.t.favorite_groups.edit_group,
    ),
  );
}
