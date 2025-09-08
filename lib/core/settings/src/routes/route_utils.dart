// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../router.dart';

void goToSettingsPage(
  WidgetRef ref, {
  String? scrollTo,
}) {
  ref.router.push(
    Uri(
      path: '/settings',
      queryParameters: {
        'scrollTo': ?scrollTo,
      },
    ).toString(),
  );
}

Future<void> openImageViewerSettingsPage(WidgetRef ref) {
  return ref.router.push(
    Uri(
      path: '/settings',
      queryParameters: {
        'initial': 'viewer',
      },
    ).toString(),
  );
}

Future<void> openDownloadSettingsPage(WidgetRef ref) {
  return ref.router.push(
    Uri(
      path: '/settings',
      queryParameters: {
        'initial': 'download',
      },
    ).toString(),
  );
}

Future<void> openAppearancePage(WidgetRef ref) {
  return ref.router.push(
    Uri(
      path: '/settings',
      queryParameters: {
        'initial': 'appearance',
      },
    ).toString(),
  );
}

Future<void> openDataAndStoragePage(WidgetRef ref) {
  return ref.router.push(
    Uri(
      path: '/settings',
      queryParameters: {
        'initial': 'data_and_storage',
      },
    ).toString(),
  );
}
