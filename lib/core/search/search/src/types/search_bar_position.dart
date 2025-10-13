// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:i18n/i18n.dart';

enum SearchBarPosition {
  top,
  bottom;

  factory SearchBarPosition.parse(dynamic value) => switch (value) {
    'top' || '0' || 0 => top,
    'bottom' || '1' || 1 => bottom,
    _ => defaultValue,
  };

  static const SearchBarPosition defaultValue = top;

  String localize(BuildContext context) => switch (this) {
    top => context.t.settings.search.search_bar.position.top,
    bottom => context.t.settings.search.search_bar.position.bottom,
  };

  dynamic toData() => index;
}
