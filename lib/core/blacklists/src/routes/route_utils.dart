// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../router.dart';

void goToGlobalBlacklistedTagsPage(WidgetRef ref) {
  ref.router.push(
    Uri(
      path: '/global_blacklisted_tags',
    ).toString(),
  );
}
