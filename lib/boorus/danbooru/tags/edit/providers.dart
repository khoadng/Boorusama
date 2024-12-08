// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/posts/rating.dart';

final selectedTagEditRatingProvider =
    StateProvider.family.autoDispose<Rating?, Rating?>((ref, rating) {
  return rating;
});
