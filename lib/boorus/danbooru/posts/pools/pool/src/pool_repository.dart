// Project imports:
import 'danbooru_pool.dart';

abstract class PoolRepository {
  Future<List<DanbooruPool>> getPools(
    int page, {
    DanbooruPoolCategory? category,
    DanbooruPoolOrder? order,
    String? name,
    String? description,
  });
  Future<List<DanbooruPool>> getPoolsByPostId(int postId);
}
