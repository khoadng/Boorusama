// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/ref.dart';
import '../../pool/pool.dart';
import '../../pool/providers.dart';

final danbooruPoolQueryProvider = StateProvider.autoDispose<String?>(
  (ref) => null,
);

enum PoolSearchMode {
  suggestion,
  result,
}

final danbooruPoolSearchModeProvider =
    StateProvider.autoDispose<PoolSearchMode>(
      (ref) => PoolSearchMode.suggestion,
    );

final poolSuggestionsProvider = FutureProvider.autoDispose
    .family<List<DanbooruPool>, String>((ref, query) async {
      if (query.isEmpty) return [];

      final config = ref.watchConfigAuth;
      final repo = ref.watch(danbooruPoolRepoProvider(config));

      return repo.getPools(
        1,
        name: query,
        order: DanbooruPoolOrder.postCount,
      );
    });
