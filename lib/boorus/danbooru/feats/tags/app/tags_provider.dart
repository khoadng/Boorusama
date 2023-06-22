// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/metatags/user_metatag_repository.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/foundation/caching/lru_cacher.dart';

part 'related_tags_provider.dart';

final popularSearchProvider = Provider<PopularSearchRepository>(
  (ref) {
    return PopularSearchRepositoryApi(
      api: ref.watch(danbooruApiProvider),
    );
  },
);

final danbooruTagRepoProvider = Provider<TagRepository>(
  (ref) {
    return TagCacher(
      cache: LruCacher(capacity: 1000),
      repo: TagRepositoryApi(
        ref.watch(danbooruApiProvider),
      ),
    );
  },
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
