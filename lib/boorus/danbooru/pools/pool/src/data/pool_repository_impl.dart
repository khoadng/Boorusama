// Project imports:
import '../../../../../../foundation/caching.dart';
import '../types/danbooru_pool.dart';
import '../types/pool_category.dart';
import '../types/pool_order.dart';

class PoolRepositoryBuilder
    with SimpleCacheMixin<List<DanbooruPool>>
    implements PoolRepository {
  PoolRepositoryBuilder({
    required this.fetchMany,
    required this.fetchByPostId,
    int maxCapacity = 1000,
    Duration staleDuration = const Duration(minutes: 10),
  }) {
    cache = Cache(
      maxCapacity: maxCapacity,
      staleDuration: staleDuration,
    );
  }

  final Future<List<DanbooruPool>> Function(
    int page, {
    DanbooruPoolCategory? category,
    DanbooruPoolOrder? order,
    String? name,
    String? description,
  })
  fetchMany;

  final Future<List<DanbooruPool>> Function(int postId) fetchByPostId;

  @override
  Future<List<DanbooruPool>> getPools(
    int page, {
    DanbooruPoolCategory? category,
    DanbooruPoolOrder? order,
    String? name,
    String? description,
  }) => fetchMany(
    page,
    category: category,
    order: order,
    name: name,
    description: description,
  );

  @override
  Future<List<DanbooruPool>> getPoolsByPostId(int postId) => tryGet(
    'pool-by-post-$postId',
    orElse: () => fetchByPostId(postId),
  );

  @override
  late Cache<List<DanbooruPool>> cache;
}
