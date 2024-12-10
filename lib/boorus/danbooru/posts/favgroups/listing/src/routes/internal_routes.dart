// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/core/configs/config.dart';
import '../../../favgroups/favgroup.dart';
import '../../../favgroups/routes.dart';
import '../pages/favorite_group_delete_confirmation_dialog.dart';
import '../widgets/modal_favorite_group_action.dart';

void showFavgroupEditSheet(
  BuildContext context,
  DanbooruFavoriteGroup favGroup,
  BooruConfigSearch config,
) {
  showMaterialModalBottomSheet(
    context: context,
    builder: (_) => ModalFavoriteGroupAction(
      onDelete: () => showDialog(
        context: context,
        builder: (context) => FavoriteGroupDeleteConfirmationDialog(
          favGroup: favGroup,
        ),
      ),
      onEdit: () => goToFavoriteGroupEditPage(context, favGroup),
    ),
  );
}
