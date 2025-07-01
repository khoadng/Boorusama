// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../router.dart';

void goToFavoritesPage(WidgetRef ref) {
  ref.router.push(
    Uri(
      path: '/favorites',
    ).toString(),
  );
}
