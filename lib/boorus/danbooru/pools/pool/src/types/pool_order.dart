// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:i18n/i18n.dart';

enum DanbooruPoolOrder {
  latest,
  newest,
  postCount,
  name;

  String localize(BuildContext context) => switch (this) {
    DanbooruPoolOrder.newest => context.t.pool.order.kNew,
    DanbooruPoolOrder.postCount => context.t.pool.order.post_count,
    DanbooruPoolOrder.name => context.t.pool.order.name,
    DanbooruPoolOrder.latest => context.t.pool.order.recent,
  };
}
