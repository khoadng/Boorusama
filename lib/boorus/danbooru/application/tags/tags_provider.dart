// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/tags.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/tags/tags.dart';
import 'package:boorusama/core/domain/tags.dart';
import 'package:boorusama/core/infra/caching/lru_cacher.dart';
import 'package:boorusama/core/infra/tags.dart';
import 'package:boorusama/core/provider.dart';

final popularSearchProvider = Provider<PopularSearchRepository>(
  (ref) {
    final api = ref.watch(danbooruApiProvider);
    final currentBooruConfigRepository =
        ref.watch(currentBooruConfigRepoProvider);

    return PopularSearchRepositoryApi(
        currentBooruConfigRepository: currentBooruConfigRepository, api: api);
  },
  dependencies: [
    currentBooruConfigRepoProvider,
  ],
);

final danbooruTagRepoProvider = Provider<TagRepository>(
  (ref) {
    final api = ref.watch(danbooruApiProvider);
    final currentBooruConfigRepo = ref.watch(currentBooruConfigRepoProvider);

    return TagCacher(
      cache: LruCacher(capacity: 1000),
      repo: TagRepositoryApi(api, currentBooruConfigRepo),
    );
  },
  dependencies: [
    currentBooruConfigRepoProvider,
  ],
);
