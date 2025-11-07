// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/router.dart';

void goToPoolSearchPage(WidgetRef ref) {
  ref.router.push(
    Uri(
      path: '/danbooru/pools/search',
    ).toString(),
  );
}
