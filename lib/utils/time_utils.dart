// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:timeago/timeago.dart' as timeago;

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

extension DateTimeX on DateTime {
  String fuzzify({
    Locale locale = const Locale('en', 'US'),
  }) {
    final now = DateTime.now();
    final ago = now.subtract(now.difference(this));

    return timeago.format(
      ago,
      locale: locale.toLanguageTag(),
    );
  }
}
