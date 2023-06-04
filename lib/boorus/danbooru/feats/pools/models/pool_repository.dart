// Project imports:
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';

abstract class PoolRepository {
  Future<List<Pool>> getPools(
    int page, {
    PoolCategory? category,
    PoolOrder? order,
    String? name,
    String? description,
  });
  Future<List<Pool>> getPoolsByPostId(int postId);
  Future<List<Pool>> getPoolsByPostIds(List<int> postIds);
}
