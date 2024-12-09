// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/parser.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/configs/ref.dart';
import '../../pool/pool.dart';
import 'pool_description_repository.dart';

final selectedPoolDetailsOrderProvider = StateProvider.autoDispose<String>(
  (ref) => 'order',
);

final poolPostIdsProvider =
    Provider.autoDispose.family<List<int>, DanbooruPool>(
  (ref, pool) {
    final selectedOrder = ref.watch(selectedPoolDetailsOrderProvider);
    final postIds = [...pool.postIds];

    final sorted = switch (selectedOrder) {
      'latest' => postIds.sorted((a, b) => b.compareTo(a)),
      'oldest' => postIds.sorted((a, b) => a.compareTo(b)),
      _ => postIds,
    };

    return sorted;
  },
);

final poolDescriptionRepoProvider =
    Provider.family<PoolDescriptionRepository, BooruConfigAuth>((ref, config) {
  return PoolDescriptionRepoBuilder(
    fetchDescription: (poolId) async {
      final html = await ref
          .watch(danbooruClientProvider(config))
          .getPoolDescriptionHtml(poolId);

      final document = parse(html);

      return document.getElementById('description')?.outerHtml ?? '';
    },
  );
});

final poolDescriptionProvider = FutureProvider.autoDispose
    .family<PoolDescriptionState, PoolId>((ref, poolId) async {
  final config = ref.watchConfigAuth;
  final repo = ref.watch(poolDescriptionRepoProvider(config));
  final desc = await repo.getDescription(poolId);

  return (
    description: desc,
    descriptionEndpointRefUrl: config.url,
  );
});

typedef PoolDescriptionState = ({
  String description,
  String descriptionEndpointRefUrl,
});
