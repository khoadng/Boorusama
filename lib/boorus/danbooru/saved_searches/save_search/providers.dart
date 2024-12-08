// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/configs/config.dart';
import 'save_search_repository.dart';

final danbooruSavedSearchRepoProvider =
    Provider.family<SavedSearchRepository, BooruConfigAuth>((ref, config) {
  return SavedSearchRepositoryApi(
    ref.watch(danbooruClientProvider(config)),
  );
});
