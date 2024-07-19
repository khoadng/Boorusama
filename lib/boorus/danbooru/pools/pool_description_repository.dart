// Project imports:
import 'package:boorusama/foundation/caching/caching.dart';

abstract class PoolDescriptionRepository {
  Future<String> getDescription(int poolId);
}

class PoolDescriptionRepoBuilder
    with SimpleCacheMixin<String>
    implements PoolDescriptionRepository {
  PoolDescriptionRepoBuilder({
    required this.fetchDescription,
    int maxCapacity = 100,
    Duration staleDuration = const Duration(minutes: 15),
  }) {
    cache = Cache(
      maxCapacity: maxCapacity,
      staleDuration: staleDuration,
    );
  }

  final Future<String> Function(int poolId) fetchDescription;

  @override
  Future<String> getDescription(int poolId) => tryGet(
        'pool_desc_$poolId',
        orElse: () => fetchDescription(poolId),
      );

  @override
  late Cache<String> cache;
}
