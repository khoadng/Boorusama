// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru.dart';
import 'package:boorusama/foundation/caching/lru_cacher.dart';
import 'gelbooru_tag_repository_api.dart';

final gelbooruTagRepoProvider = Provider<TagRepository>(
  (ref) {
    final api = ref.watch(gelbooruClientProvider);

    return TagCacher(
      cache: LruCacher(capacity: 1000),
      repo: GelbooruTagRepositoryApi(api),
    );
  },
);
