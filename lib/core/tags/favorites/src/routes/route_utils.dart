// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../router.dart';

void goToFavoriteTagsPage(WidgetRef ref) {
  ref.router.push(
    Uri(
      path: '/favorite_tags',
    ).toString(),
  );
}
