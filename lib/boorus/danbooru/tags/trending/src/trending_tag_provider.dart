// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config.dart';
import '../../../client_provider.dart';
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
