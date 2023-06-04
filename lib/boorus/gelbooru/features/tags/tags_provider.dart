// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/gelbooru_provider.dart';
import 'package:boorusama/core/infra/caching/lru_cacher.dart';
import 'package:boorusama/core/infra/tags.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'gelbooru_tag_repository_api.dart';

final gelbooruTagRepoProvider = Provider<TagRepository>(
  (ref) {
    final api = ref.watch(gelbooruApiProvider);

    return TagCacher(
      cache: LruCacher(capacity: 1000),
      repo: GelbooruTagRepositoryApi(api),
    );
  },
);
