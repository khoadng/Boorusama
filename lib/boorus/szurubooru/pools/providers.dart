// Package imports:
import 'package:booru_clients/szurubooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import '../../../core/configs/config/types.dart';
import '../../../core/posts/pools/widgets.dart';
import '../client_provider.dart';
import 'types.dart';

final szurubooruPoolRepoProvider =
    Provider.family<SzurubooruPoolRepository, BooruConfigAuth>((ref, config) {
      final client = ref.watch(szurubooruClientProvider(config));

      return SzurubooruPoolRepository(client);
    });

class SzurubooruPoolRepository {
  const SzurubooruPoolRepository(this.client);

  final SzurubooruClient client;

  Future<List<SzurubooruPool>> getPools({
    required int page,
    required SzurubooruPoolOrder order,
    String? name,
    int limit = 20,
  }) async {
    final query = _poolQuery(
      order: order,
      name: name,
    );

    final pools = await client.getPools(
      offset: (page - 1) * limit,
      limit: limit,
      query: query,
    );

    return pools.map(poolDtoToSzurubooruPool).nonNulls.toList();
  }

  Future<SzurubooruPool?> getPool(int id) async {
    final pool = await client.getPool(id);

    return poolDtoToSzurubooruPool(pool);
  }
}

SzurubooruPool? poolDtoToSzurubooruPool(PoolDto dto) => switch (dto.id) {
  null => null,
  final id => SzurubooruPool(
    id: id,
    names: dto.names ?? const [],
    category: dto.category,
    description: dto.description,
    postCount: dto.postCount,
    postIds: dto.posts?.map((e) => e.id).nonNulls.toList() ?? const [],
    thumbnailUrls:
        dto.posts?.map((e) => e.thumbnailUrl).nonNulls.toList() ?? const [],
    createdAt: DateTime.tryParse(dto.creationTime ?? ''),
    updatedAt: DateTime.tryParse(dto.lastEditTime ?? ''),
  ),
};

String _poolQuery({
  required SzurubooruPoolOrder order,
  String? name,
}) {
  final tokens = [
    if (name != null && name.trim().isNotEmpty) _nameToken(name.trim()),
    _orderToken(order),
  ];

  return tokens.join(' ');
}

String _nameToken(String name) {
  final query = name.length < 3 ? '$name*' : '*$name*';

  return query.replaceAll(' ', r'\ ');
}

String _orderToken(SzurubooruPoolOrder order) => switch (order) {
  SzurubooruPoolOrder.latest => 'sort:last-edit-time',
  SzurubooruPoolOrder.newest => 'sort:creation-time',
  SzurubooruPoolOrder.postCount => 'sort:post-count',
  SzurubooruPoolOrder.name => 'sort:name',
};

final szurubooruPoolFilterProvider =
    NotifierProvider<_SzurubooruPoolFilterNotifier, SzurubooruPoolOrder>(
      _SzurubooruPoolFilterNotifier.new,
    );

class _SzurubooruPoolFilterNotifier extends Notifier<SzurubooruPoolOrder> {
  @override
  SzurubooruPoolOrder build() {
    return SzurubooruPoolOrder.latest;
  }

  void setOrder(SzurubooruPoolOrder order) {
    state = order;
  }
}

final szurubooruPoolDetailsOrderProvider = StateProvider.autoDispose
    .family<PoolDetailsOrder, int>(
      (ref, poolId) => PoolDetailsOrder.order,
    );

final szurubooruPoolQueryProvider = StateProvider.autoDispose<String?>(
  (ref) => null,
);

enum SzurubooruPoolSearchMode {
  suggestion,
  result,
}

final szurubooruPoolSearchModeProvider =
    StateProvider.autoDispose<SzurubooruPoolSearchMode>(
      (ref) => SzurubooruPoolSearchMode.suggestion,
    );

final szurubooruPoolSuggestionsProvider = FutureProvider.autoDispose
    .family<List<SzurubooruPool>, String>((ref, query) {
      if (query.isEmpty) return [];

      final config = ref.watchConfigAuth;
      final repo = ref.watch(szurubooruPoolRepoProvider(config));

      return repo.getPools(
        page: 1,
        order: SzurubooruPoolOrder.postCount,
        name: query,
      );
    });

final szurubooruPoolProvider = FutureProvider.autoDispose
    .family<SzurubooruPool?, (BooruConfigAuth, int)>((ref, params) {
      final (config, poolId) = params;
      final repo = ref.watch(szurubooruPoolRepoProvider(config));

      return repo.getPool(poolId);
    });
