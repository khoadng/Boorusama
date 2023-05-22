// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/tags.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/tags.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/tags/tags.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/domain/tags.dart';
import 'package:boorusama/core/infra/caching/lru_cacher.dart';
import 'package:boorusama/core/infra/repositories/metatags.dart';
import 'package:boorusama/core/infra/tags.dart';
import 'related_tags_notifier.dart';

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
