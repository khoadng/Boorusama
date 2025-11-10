// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:i18n/i18n.dart';

enum SlideshowVideoBehavior {
  waitForCompletion,
  fixedInterval;

  factory SlideshowVideoBehavior.parse(dynamic value) => switch (value) {
    'waitForCompletion' || '0' || 0 => waitForCompletion,
    'fixedInterval' || '1' || 1 => fixedInterval,
    _ => defaultValue,
  };

  bool get isWaitForCompletion => this == waitForCompletion;

  static const SlideshowVideoBehavior defaultValue = waitForCompletion;

  String localize(BuildContext context) => switch (this) {
    waitForCompletion =>
      context
          .t
          .settings
          .image_viewer
          .slideshow_video_behaviors
          .wait_for_completion,
    fixedInterval =>
      context.t.settings.image_viewer.slideshow_video_behaviors.fixed_interval,
  };

  dynamic toData() => index;
}
