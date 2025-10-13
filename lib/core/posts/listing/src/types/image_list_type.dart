// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:i18n/i18n.dart';

enum ImageListType {
  standard,
  masonry,
  classic;

  factory ImageListType.parse(dynamic value) => switch (value) {
    'standard' || '0' || 0 => standard,
    'masonry' || '1' || 1 => masonry,
    'classic' || '2' || 2 => classic,
    _ => defaultValue,
  };

  static const ImageListType defaultValue = masonry;

  String localize(BuildContext context) => switch (this) {
    standard => context.t.settings.image_list.standard,
    masonry => context.t.settings.image_list.masonry,
    classic => context.t.settings.image_list.classic,
  };

  dynamic toData() => index;
}
