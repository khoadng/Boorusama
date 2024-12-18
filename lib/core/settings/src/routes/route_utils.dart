// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../../../router.dart';

void goToSettingsPage(
  BuildContext context, {
  String? scrollTo,
}) {
  context.push(
    Uri(
      path: '/settings',
      queryParameters: {
        if (scrollTo != null) 'scrollTo': scrollTo,
      },
    ).toString(),
  );
}

Future<void> openImageViewerSettingsPage(BuildContext context) {
  return context.push(
    Uri(
      path: '/settings',
      queryParameters: {
        'initial': 'viewer',
      },
    ).toString(),
  );
}

Future<void> openDownloadSettingsPage(BuildContext context) {
  return context.push(
    Uri(
      path: '/settings',
      queryParameters: {
        'initial': 'download',
      },
    ).toString(),
  );
}

Future<void> openAppearancePage(BuildContext context) {
  return context.push(
    Uri(
      path: '/settings',
      queryParameters: {
        'initial': 'appearance',
      },
    ).toString(),
  );
}
