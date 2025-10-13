// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:i18n/i18n.dart';

enum SlideshowDirection {
  forward,
  backward,
  random;

  factory SlideshowDirection.parse(dynamic value) => switch (value) {
    'forward' || '0' || 0 => forward,
    'backward' || '1' || 1 => backward,
    'random' || '2' || 2 => random,
    _ => defaultValue,
  };

  static const SlideshowDirection defaultValue = forward;

  String localize(BuildContext context) => switch (this) {
    forward => context.t.settings.image_viewer.slideshow_modes.forward,
    backward => context.t.settings.image_viewer.slideshow_modes.backward,
    random => context.t.settings.image_viewer.slideshow_modes.random,
  };

  dynamic toData() => index;
}
