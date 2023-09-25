// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/gelbooru.dart';
import 'gelbooru_autocomplete_repository_api.dart';

final gelbooruAutocompleteRepoProvider =
    Provider<GelbooruAutocompleteRepositoryApi>((ref) {
  final api = ref.watch(gelbooruClientProvider);

  return GelbooruAutocompleteRepositoryApi(api);
});
