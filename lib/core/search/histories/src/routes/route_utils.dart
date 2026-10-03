// Package imports:
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../../router.dart';
import '../full_history_page.dart';
import '../types/search_history.dart';

void goToSearchHistoryPage(
  BuildContext context, {
  required Function(BuildContext context, SearchHistory history) onTap,
}) {
  Kurumi.showModalBottomSheet(
    context: context,
    routeSettings: const RouteSettings(
      name: RouterPageConstant.searchHistories,
    ),
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) => FullHistoryPage(
      onTap: onTap,
    ),
  );
}
