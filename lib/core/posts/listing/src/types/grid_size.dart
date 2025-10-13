// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:i18n/i18n.dart';

enum GridSize {
  small,
  normal,
  large,
  tiny,
  micro;

  factory GridSize.parse(dynamic value) => switch (value) {
    'small' || '0' || 0 => small,
    'normal' || '1' || 1 => normal,
    'large' || '2' || 2 => large,
    'tiny' || '3' || 3 => tiny,
    'micro' || '4' || 4 => micro,
    _ => defaultValue,
  };

  static const GridSize defaultValue = normal;

  String localize(BuildContext context) => switch (this) {
    micro => context.t.settings.image_grid.grid_size.micro,
    tiny => context.t.settings.image_grid.grid_size.tiny,
    large => context.t.settings.image_grid.grid_size.large,
    small => context.t.settings.image_grid.grid_size.small,
    normal => context.t.settings.image_grid.grid_size.medium,
  };

  dynamic toData() => index;

  static const sortedValues = [
    micro,
    tiny,
    small,
    normal,
    large,
  ];
}
