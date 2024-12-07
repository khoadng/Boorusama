// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/configs.dart';
import 'popular_search_repository.dart';
import 'popular_search_repository_api.dart';

final popularSearchProvider =
    Provider.family<PopularSearchRepository, BooruConfigAuth>(
  (ref, config) {
    return PopularSearchRepositoryApi(
      client: ref.watch(danbooruClientProvider(config)),
    );
  },
);
