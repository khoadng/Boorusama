// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import '../types/danbooru_pool.dart';
import '../types/pool_category.dart';
import '../types/pool_order.dart';

DanbooruPool? poolDtoToDanbooruPool(PoolDto dto) => switch (dto.id) {
  null => null,
  final id => DanbooruPool(
    id: id,
    postIds: dto.postIds,
    category: DanbooruPoolCategory.parse(dto.category),
    description: dto.description,
    postCount: dto.postCount,
    name: dto.name,
    createdAt: dto.createdAt,
    updatedAt: dto.updatedAt,
  ),
};

PoolCategory? danbooruPoolCategoryToPoolCategory(
  DanbooruPoolCategory? category,
) => switch (category) {
  DanbooruPoolCategory.collection => PoolCategory.collection,
  DanbooruPoolCategory.series => PoolCategory.series,
  DanbooruPoolCategory.unknown => null,
  null => null,
};

PoolOrder? danbooruPoolOrderToPoolOrder(DanbooruPoolOrder? order) =>
    switch (order) {
      DanbooruPoolOrder.newest => PoolOrder.createdAt,
      DanbooruPoolOrder.latest => PoolOrder.updatedAt,
      DanbooruPoolOrder.postCount => PoolOrder.postCount,
      DanbooruPoolOrder.name => PoolOrder.name,
      null => null,
    };
