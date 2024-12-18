// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../types/blacklisted_tags_sort_type.dart';

final selectedBlacklistedTagQueryProvider =
    StateProvider.autoDispose<String>((ref) {
  return '';
});

final selectedBlacklistedTagsSortTypeProvider =
    StateProvider.autoDispose<BlacklistedTagsSortType>((ref) {
  return BlacklistedTagsSortType.recentlyAdded;
});
