import 'package:boorusama/boorus/danbooru/domain/pools.dart';

class EmptyPoolRepository implements PoolRepository {
  @override
  Future<List<Pool>> getPools(
    int page, {
    PoolCategory? category,
    PoolOrder? order,
    String? name,
    String? description,
  }) async =>
      [];

  @override
  Future<List<Pool>> getPoolsByPostId(int postId) async => [];

  @override
  Future<List<Pool>> getPoolsByPostIds(List<int> postIds) async => [];
}
