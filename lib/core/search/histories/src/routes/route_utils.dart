// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import '../../../../foundation/animations.dart';
import '../../../../router.dart';
import '../full_history_page.dart';
import '../search_history.dart';

void goToSearchHistoryPage(
  BuildContext context, {
  required Function() onClear,
  required Function(SearchHistory history) onRemove,
  required Function(SearchHistory history) onTap,
}) {
  showMaterialModalBottomSheet(
    context: context,
    settings: const RouteSettings(
      name: RouterPageConstant.searchHistories,
    ),
    duration: AppDurations.bottomSheet,
    builder: (context) => FullHistoryPage(
      onClear: onClear,
      onRemove: onRemove,
      onTap: onTap,
      scrollController: ModalScrollController.of(context),
    ),
  );
}
