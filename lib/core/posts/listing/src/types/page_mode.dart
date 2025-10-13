// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:i18n/i18n.dart';

enum PageMode {
  infinite,
  paginated;

  factory PageMode.parse(dynamic value) => switch (value) {
    'infinite' || '0' || 0 => infinite,
    'paginated' || '1' || 1 => paginated,
    _ => defaultValue,
  };

  static const PageMode defaultValue = infinite;

  String localize(BuildContext context) => switch (this) {
    infinite => context.t.settings.result_layout.infinite_scroll,
    paginated => context.t.settings.result_layout.pagination,
  };

  dynamic toData() => index;
}
