// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../router.dart';
import '../full_history_page.dart';
import '../types/search_history.dart';

void goToSearchHistoryPage(
  BuildContext context, {
  required Function(BuildContext context, SearchHistory history) onTap,
}) {
  showModalBottomSheet(
    context: context,
    routeSettings: const RouteSettings(
      name: RouterPageConstant.searchHistories,
    ),
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => FullHistoryPage(
      onTap: onTap,
    ),
  );
}
