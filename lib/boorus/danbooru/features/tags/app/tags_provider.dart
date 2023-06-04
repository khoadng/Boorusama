// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/boorus/providers.dart';
import 'package:boorusama/boorus/core/metatags/user_metatag_repository.dart';
import 'package:boorusama/boorus/core/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/features/tags/tags.dart';
import 'package:boorusama/foundation/caching/lru_cacher.dart';

part 'related_tags_provider.dart';

final popularSearchProvider = Provider<PopularSearchRepository>(
  (ref) {
    final api = ref.watch(danbooruApiProvider);
    final booruConfig = ref.watch(currentBooruConfigProvider);

    return PopularSearchRepositoryApi(
      booruConfig: booruConfig,
      api: api,
    );
  },
  dependencies: [
    currentBooruConfigProvider,
  ],
);

final danbooruTagRepoProvider = Provider<TagRepository>(
  (ref) {
    final api = ref.watch(danbooruApiProvider);
    final booruConfig = ref.watch(currentBooruConfigProvider);

    return TagCacher(
      cache: LruCacher(capacity: 1000),
      repo: TagRepositoryApi(api, booruConfig),
    );
  },
  dependencies: [
    currentBooruConfigProvider,
  ],
);

final danbooruUserMetatagRepoProvider = Provider<UserMetatagRepository>((ref) {
  throw UnimplementedError();
});

final danbooruUserMetatagsProvider =
    NotifierProvider<UserMetatagsNotifier, List<String>>(
  UserMetatagsNotifier.new,
  dependencies: [
    danbooruUserMetatagRepoProvider,
  ],
);
