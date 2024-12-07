// Project imports:
import '../pool/danbooru_pool.dart';

String poolOrderToString(DanbooruPoolOrder order) => switch (order) {
      DanbooruPoolOrder.newest => 'pool.order.new',
      DanbooruPoolOrder.postCount => 'pool.order.post_count',
      DanbooruPoolOrder.name => 'pool.order.name',
      DanbooruPoolOrder.latest => 'pool.order.recent',
    };
