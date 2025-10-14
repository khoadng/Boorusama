// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/posts/rating/types.dart';

final selectedTagEditRatingProvider = StateProvider.family
    .autoDispose<Rating?, Rating?>((ref, rating) {
      return rating;
    });
