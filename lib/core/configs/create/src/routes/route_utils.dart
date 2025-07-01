// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../router.dart';
import '../../../config/types.dart';

void goToUpdateBooruConfigPage(
  WidgetRef ref, {
  required BooruConfig config,
  String? initialTab,
}) {
  ref.router.push(
    Uri(
      path: '/boorus/${config.id}/update',
      queryParameters: {
        if (initialTab != null) 'q': initialTab,
      },
    ).toString(),
  );
}

void goToAddBooruConfigPage(
  WidgetRef ref,
) {
  ref.router.push(
    Uri(
      path: '/boorus/add',
    ).toString(),
  );
}
