// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:i18n/i18n.dart';

enum BooruConfigLabelVisibility {
  always,
  never;

  factory BooruConfigLabelVisibility.parse(dynamic value) => switch (value) {
    'always' || '0' || 0 => always,
    'never' || '1' || 1 => never,
    _ => defaultValue,
  };

  static const BooruConfigLabelVisibility defaultValue = always;

  bool get hideBooruConfigLabel => this == never;

  String localize(BuildContext context) => switch (this) {
    always => context.t.settings.appearance.booru_config_label_options.always,
    never => context.t.settings.appearance.booru_config_label_options.never,
  };

  dynamic toData() => index;
}
