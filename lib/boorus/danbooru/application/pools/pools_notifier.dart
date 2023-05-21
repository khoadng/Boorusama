// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_infinite_scroll/riverpod_infinite_scroll.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';

class PoolKey extends Equatable {
  final int page;
  final String? name;
  final String? description;

  const PoolKey({
    required this.page,
    this.name,
    this.description,
  });

  @override
  List<Object?> get props => [
        page,
        name,
        description,
      ];
}

class PoolsNotifier extends PagedNotifier<PoolKey, Pool> {
  PoolsNotifier({
    required PoolRepository repo,
    required PoolCategory category,
    required PoolOrder order,
    required Ref ref,
  }) : super(
          load: (key, limit) async {
            final pools = await repo.getPools(
              key.page,
              category: category,
              order: order,
              name: key.name,
              description: key.description,
            );

            ref.read(danbooruPoolCoversProvider.notifier).load(pools);

            return pools;
          },
          nextPageKeyBuilder: (records, key, limit) =>
              (records == null || records.length < limit)
                  ? null
                  : PoolKey(
                      page: key.page + 1,
                      name: key.name,
                      description: key.description,
                    ),
        );
}
