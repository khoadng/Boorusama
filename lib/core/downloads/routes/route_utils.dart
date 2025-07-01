// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../router.dart';

void goToDownloadManagerPage(
  WidgetRef ref,
) {
  ref.router.push(
    Uri(
      path: '/download_manager',
    ).toString(),
  );
}
