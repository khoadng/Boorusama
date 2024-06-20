// Project imports:
import 'package:boorusama/time.dart';
import 'types.dart';

extension DateTimeX on DateTime {
  Jiffy asJiffy() => Jiffy.parseFromDateTime(this);

  DateTime subtractTimeScale(TimeScale scale) => switch (scale) {
        TimeScale.day => asJiffy().subtract(days: 1).dateTime,
        TimeScale.week => asJiffy().subtract(weeks: 1).dateTime,
        TimeScale.month => asJiffy().subtract(months: 1).dateTime
      };

  DateTime addTimeScale(TimeScale scale) => switch (scale) {
        TimeScale.day => asJiffy().add(days: 1).dateTime,
        TimeScale.week => asJiffy().add(weeks: 1).dateTime,
        TimeScale.month => asJiffy().add(months: 1).dateTime
      };
}
