import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/saved_searches.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/saved_searches/save_search_repository_api.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final danbooruSavedSearchRepoProvider = Provider<SavedSearchRepository>((ref) {
  final api = ref.watch(danbooruApiProvider);
  final booruConfig = ref.watch(currentBooruConfigProvider);

  return SavedSearchRepositoryApi(api, booruConfig);
});
