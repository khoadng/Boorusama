// Package imports:
import 'package:jiffy/jiffy.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';

enum ExploreCategory {
  popular,
  mostViewed,
  hot,
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
