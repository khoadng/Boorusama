// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:i18n/i18n.dart';

enum PoolDetailsOrder {
  order,
  latest,
  oldest;

  String localize(BuildContext context) => switch (this) {
    PoolDetailsOrder.order => context.t.explore.ordered,
    PoolDetailsOrder.latest => context.t.explore.latest,
    PoolDetailsOrder.oldest => context.t.explore.oldest,
  };
}
