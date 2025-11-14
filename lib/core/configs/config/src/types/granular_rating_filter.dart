// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../../posts/rating/types.dart';

class GranularRatingFilter extends Equatable {
  const GranularRatingFilter(this.ratings);

  const GranularRatingFilter.empty() : ratings = const {};

  factory GranularRatingFilter.fromStringSet(Set<String> ratings) =>
      GranularRatingFilter(
        ratings.map((e) => Rating.parse(e)).toSet(),
      );

  static GranularRatingFilter? parse(dynamic value) {
    return switch (value) {
      final String s => GranularRatingFilter.fromStringSet(
        s.split('|').toSet(),
      ),
      final Set<Rating> ratings => GranularRatingFilter(ratings),
      final Set<String> ratingStrings => GranularRatingFilter.fromStringSet(
        ratingStrings,
      ),
      _ => null,
    };
  }

  final Set<Rating> ratings;

  GranularRatingFilter withoutUnknown() => GranularRatingFilter(
    ratings.where((e) => e != Rating.unknown).toSet(),
  );

  String toFilterString({bool sort = false}) => switch (ratings.isEmpty) {
    true => '',
    false =>
      (sort
              ? ratings.map((e) => e.toShortString()).sorted()
              : ratings.map((e) => e.toShortString()))
          .join('|'),
  };

  @override
  List<Object?> get props => [ratings];
}
