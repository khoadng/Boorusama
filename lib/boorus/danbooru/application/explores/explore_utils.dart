// Package imports:
import 'package:equatable/equatable.dart';
import 'package:jiffy/jiffy.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';

enum ExploreCategory {
  popular,
  mostViewed,
  hot,
}

class ExploreDetailsData extends Equatable {
  final TimeScale scale;
  final DateTime date;
  final ExploreCategory category;

  const ExploreDetailsData({
    required this.scale,
    required this.date,
    required this.category,
  });

  ExploreDetailsData copyWith({
    TimeScale? scale,
    DateTime? date,
    ExploreCategory? category,
  }) {
    return ExploreDetailsData(
      scale: scale ?? this.scale,
      date: date ?? this.date,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [scale, date, category];
}

extension DateTimeX on DateTime {
  DateTime subtractTimeScale(TimeScale scale) {
    switch (scale) {
      case TimeScale.day:
        return Jiffy(this).subtract(days: 1).dateTime;
      case TimeScale.week:
        return Jiffy(this).subtract(weeks: 1).dateTime;
      case TimeScale.month:
        return Jiffy(this).subtract(months: 1).dateTime;
    }
  }

  DateTime addTimeScale(TimeScale scale) {
    switch (scale) {
      case TimeScale.day:
        return Jiffy(this).add(days: 1).dateTime;
      case TimeScale.week:
        return Jiffy(this).add(weeks: 1).dateTime;
      case TimeScale.month:
        return Jiffy(this).add(months: 1).dateTime;
    }
  }
}
