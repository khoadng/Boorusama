// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/core/theme.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/router.dart';
import '../save_search/saved_search.dart';
import 'edit_saved_search_sheet.dart';

void goToSavedSearchCreatePage(
  BuildContext context, {
  String? initialValue,
}) {
  if (kPreferredLayout.isMobile) {
    showMaterialModalBottomSheet(
      context: context,
      settings: const RouteSettings(
        name: RouterPageConstant.savedSearchCreate,
      ),
      backgroundColor: context.colorScheme.surfaceContainer,
      builder: (_) => CreateSavedSearchSheet(
        initialValue: initialValue,
      ),
    );
  } else {
    showGeneralDialog(
      context: context,
      routeSettings: const RouteSettings(
        name: RouterPageConstant.savedSearchCreate,
      ),
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      pageBuilder: (context, _, __) {
        return Dialog(
          child: Container(
            width: context.screenWidth * 0.8,
            height: context.screenHeight * 0.8,
            margin: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            child: CreateSavedSearchSheet(
              initialValue: initialValue,
            ),
          ),
        );
      },
    );
  }
}

void goToSavedSearchPatchPage(
  BuildContext context,
  SavedSearch savedSearch,
) {
  showMaterialModalBottomSheet(
    context: context,
    settings: const RouteSettings(
      name: RouterPageConstant.savedSearchPatch,
    ),
    backgroundColor: context.colorScheme.surfaceContainer,
    builder: (_) => EditSavedSearchSheet(
      savedSearch: savedSearch,
    ),
  );
}
