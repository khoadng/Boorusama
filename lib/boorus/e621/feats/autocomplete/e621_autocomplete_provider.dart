// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/e621/e621_provider.dart';
import 'e621_autocomplete_repository.dart';

final e621AutocompleteRepoProvider =
    Provider<E621AutocompleteRepository>((ref) {
  return E621AutocompleteRepository(
    ref.watch(e621ClientProvider),
  );
});
