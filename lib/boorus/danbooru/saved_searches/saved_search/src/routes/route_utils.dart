// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/foundation/display.dart';
import '../../../../../../core/router.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../pages/edit_saved_search_sheet.dart';
import '../types/saved_search.dart';

void goToSavedSearchCreatePage(
  BuildContext context, {
  String? initialValue,
}) {
  if (kPreferredLayout.isMobile) {
    showBooruModalBottomSheet(
      context: context,
      resizeToAvoidBottomInset: true,
      routeSettings: const RouteSettings(
        name: RouterPageConstant.savedSearchCreate,
      ),
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
  showBooruModalBottomSheet(
    context: context,
    resizeToAvoidBottomInset: true,
    routeSettings: const RouteSettings(
      name: RouterPageConstant.savedSearchPatch,
    ),
    builder: (_) => EditSavedSearchSheet(
      savedSearch: savedSearch,
    ),
  );
}

void goToSavedSearchEditPage(WidgetRef ref) {
  ref.router.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'saved_searches',
      ],
    ).toString(),
  );
}
