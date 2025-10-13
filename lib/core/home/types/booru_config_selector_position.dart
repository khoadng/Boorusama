// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:i18n/i18n.dart';

enum BooruConfigSelectorPosition {
  side,
  bottom;

  factory BooruConfigSelectorPosition.parse(dynamic value) => switch (value) {
    'side' || '0' || 0 => side,
    'bottom' || '1' || 1 => bottom,
    _ => defaultValue,
  };

  static const BooruConfigSelectorPosition defaultValue = side;

  bool get isSide => this == side;
  bool get isBottom => this == bottom;

  String localize(BuildContext context) => switch (this) {
    side => context.t.settings.appearance.booru_config_placement_options.side,
    bottom =>
      context.t.settings.appearance.booru_config_placement_options.bottom,
  };

  dynamic toData() => index;
}
