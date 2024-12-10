// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import '../../../../../../foundation/display.dart';
import '../../../../../../router.dart';
import '../pages/edit_saved_search_sheet.dart';
import '../types/saved_search.dart';

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
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
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
            width: MediaQuery.sizeOf(context).width * 0.8,
            height: MediaQuery.sizeOf(context).height * 0.8,
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
    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
    builder: (_) => EditSavedSearchSheet(
      savedSearch: savedSearch,
    ),
  );
}

void goToSavedSearchEditPage(BuildContext context) {
  context.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'saved_searches',
      ],
    ).toString(),
  );
}
