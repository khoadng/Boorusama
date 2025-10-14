// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../boorus/engine/providers.dart';
import '../../../configs/config/types.dart';
import '../../post/providers.dart';
import 'post_count_repository.dart';

final postCountProvider = FutureProvider.autoDispose
    .family<int?, (BooruConfigSearch, String)>((ref, params) async {
      final (config, tags) = params;
      final fetcher = ref.watch(postCountRepoProvider(config));
      final tagComposer = ref.watch(postRepoProvider(config)).tagComposer;

      if (fetcher == null) return null;

      final postCount = await fetcher.count(
        tagComposer.compose(tags.split(' ')),
      );

      return postCount;
    });

final cachedPostCountProvider =
    FutureProvider.family<int?, (BooruConfigSearch, String)>(
      (ref, params) => ref.watch(postCountProvider(params).future),
    );

final emptyPostCountRepoProvider = Provider<PostCountRepository>(
  (ref) => const EmptyPostCountRepository(),
);

final postCountRepoProvider =
    Provider.family<PostCountRepository?, BooruConfigSearch>(
      (ref, config) {
        final repo = ref
            .watch(booruEngineRegistryProvider)
            .getRepository(config.booruType);
        return repo?.postCount(config);
      },
    );
