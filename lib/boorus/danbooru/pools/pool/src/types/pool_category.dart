// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:i18n/i18n.dart';

enum DanbooruPoolCategory {
  unknown,
  collection,
  series;

  factory DanbooruPoolCategory.parse(dynamic value) => switch (value) {
    final String v => switch (v.toLowerCase()) {
      'collection' => DanbooruPoolCategory.collection,
      'series' => DanbooruPoolCategory.series,
      _ => DanbooruPoolCategory.unknown,
    },
    final int v => switch (v) {
      0 => DanbooruPoolCategory.collection,
      _ => DanbooruPoolCategory.series,
    },
    _ => DanbooruPoolCategory.unknown,
  };

  int toInt() => switch (this) {
    DanbooruPoolCategory.collection => 0,
    DanbooruPoolCategory.series => 1,
    DanbooruPoolCategory.unknown => -1,
  };

  static const List<DanbooruPoolCategory> allValues = [
    DanbooruPoolCategory.collection,
    DanbooruPoolCategory.series,
  ];

  String localize(BuildContext context) => switch (this) {
    DanbooruPoolCategory.unknown => '???',
    DanbooruPoolCategory.collection => context.t.pool.category.collection,
    DanbooruPoolCategory.series => context.t.pool.category.series,
  };
}
