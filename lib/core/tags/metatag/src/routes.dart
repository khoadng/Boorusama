// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../foundation/display.dart';
import '../../../router.dart';
import 'pages/metatag_list_page.dart';
import 'types/metatag.dart';

void goToMetatagsPage(
  BuildContext context, {
  required List<Metatag> metatags,
  required void Function(Metatag tag) onSelected,
}) {
  showAdaptiveBottomSheet(
    context,
    settings: const RouteSettings(
      name: RouterPageConstant.metatags,
    ),
    builder: (context) => MetatagListPage(
      metatags: metatags,
      onSelected: onSelected,
    ),
  );
}
