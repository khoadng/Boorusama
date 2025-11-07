// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../pool/types.dart';

String poolOrderToString(BuildContext context, DanbooruPoolOrder order) =>
    switch (order) {
      DanbooruPoolOrder.newest => context.t.pool.order.kNew,
      DanbooruPoolOrder.postCount => context.t.pool.order.post_count,
      DanbooruPoolOrder.name => context.t.pool.order.name,
      DanbooruPoolOrder.latest => context.t.pool.order.recent,
    };
