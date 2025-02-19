// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../router.dart';

void goToDownloadManagerPage(
  BuildContext context,
) {
  context.push(
    Uri(
      path: '/download_manager',
    ).toString(),
  );
}
