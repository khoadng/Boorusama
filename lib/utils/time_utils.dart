// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:boorusama/time.dart';

String formatDurationForMedia(Duration duration) {
  final seconds = duration.inSeconds % 60;
  final minutes = duration.inMinutes % 60;
  final hours = duration.inHours;

  final secondsStr = seconds.toString().padLeft(2, '0');
  final minutesStr = minutes.toString();
  final hoursStr = hours.toString();

  if (hours > 0) {
    return '$hoursStr:$minutesStr:$secondsStr';
  } else {
    return '$minutesStr:$secondsStr';
  }
}

int? parseMonthStringToInt(String value) => switch (value) {
      'Jan' => 1,
      'Feb' => 2,
      'Mar' => 3,
      'Apr' => 4,
      'May' => 5,
      'Jun' => 6,
      'Jul' => 7,
      'Aug' => 8,
      'Sep' => 9,
      'Oct' => 10,
      'Nov' => 11,
      'Dec' => 12,
      _ => null,
    };

String parseIntToMonthString(int value) => switch (value) {
      1 => 'Jan',
      2 => 'Feb',
      3 => 'Mar',
      4 => 'Apr',
      5 => 'May',
      6 => 'Jun',
      7 => 'Jul',
      8 => 'Aug',
      9 => 'Sep',
      10 => 'Oct',
      11 => 'Nov',
      12 => 'Dec',
      _ => '',
    };

DateTime? parseRFC822String(String input) {
  try {
    final parts = input.split(' ');

    final monthStr = parts[1];
    final day = parts[2];
    final time = parts[3];
    final offset = parts[4];
    final year = parts[5];

    final month = parseMonthStringToInt(monthStr)!;

    // Construct an ISO8601 string
    final iso8601 =
        '$year-${month < 10 ? "0$month" : month}-${day}T$time$offset';

    // Parse it to DateTime
    final dt = DateTime.parse(iso8601);

    return dt;
  } catch (e) {
    return null;
  }
}

extension DateTimeX on DateTime {
  String fuzzify({
    Locale locale = const Locale('en', 'US'),
  }) {
    final now = DateTime.now();
    final ago = now.subtract(now.difference(this));

    return format(
      ago,
      locale: locale.toLanguageTag(),
    );
  }

  String yyyyMMddWithHyphen() => DateFormat('yyyy-MM-dd').format(this);

  DateTime dateOnly() => DateTime(year, month, day);
}
