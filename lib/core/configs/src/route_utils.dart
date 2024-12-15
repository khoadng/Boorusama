// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../../router.dart';
import 'booru_config.dart';

void goToUpdateBooruConfigPage(
  BuildContext context, {
  required BooruConfig config,
  String? initialTab,
}) {
  context.push(
    Uri(
      path: '/boorus/${config.id}/update',
      queryParameters: {
        if (initialTab != null) 'q': initialTab,
      },
    ).toString(),
  );
}

void goToAddBooruConfigPage(
  BuildContext context,
) {
  context.push(
    Uri(
      path: '/boorus/add',
    ).toString(),
  );
}
