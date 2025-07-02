// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/config.dart';
import '../../../../client_provider.dart';
import '../data/save_search_repository_api.dart';
import '../types/saved_search_repository.dart';

final danbooruSavedSearchRepoProvider =
    Provider.family<SavedSearchRepository, BooruConfigAuth>((ref, config) {
  return SavedSearchRepositoryApi(
    ref.watch(danbooruClientProvider(config)),
  );
});
