// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:i18n/i18n.dart';

enum PageIndicatorPosition {
  top,
  bottom,
  both;

  factory PageIndicatorPosition.parse(dynamic value) => switch (value) {
    'top' || '0' || 0 => top,
    'bottom' || '1' || 1 => bottom,
    'both' || '2' || 2 => both,
    _ => defaultValue,
  };

  static const PageIndicatorPosition defaultValue = bottom;

  bool get isVisibleAtBottom => this == bottom || this == both;
  bool get isVisibleAtTop => this == top || this == both;

  dynamic toData() => index;

  String localize(BuildContext context) => switch (this) {
    top => context.t.settings.page_indicator.top,
    bottom => context.t.settings.page_indicator.bottom,
    both => context.t.settings.page_indicator.both,
  };
}
