// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../../../../router.dart';

void goToFavoritesPage(BuildContext context) {
  context.push(
    Uri(
      path: '/favorites',
    ).toString(),
  );
}
