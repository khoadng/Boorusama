// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/e621/feats/autocomplete/e621_autocomplete_repository.dart';
import 'package:boorusama/boorus/e621/feats/tags/e621_tag_provider.dart';

final e621AutocompleteRepoProvider =
    Provider<E621AutocompleteRepository>((ref) {
  return E621AutocompleteRepository(
    ref.watch(e621TagRepoProvider),
  );
});
