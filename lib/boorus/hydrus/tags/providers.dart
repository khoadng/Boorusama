// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/autocompletes/autocompletes.dart';
import '../../../core/configs/config/types.dart';
import '../client_provider.dart';
import 'parser.dart';

final hydrusAutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>((ref, config) {
  final client = ref.watch(hydrusClientProvider(config));

  return AutocompleteRepositoryBuilder(
    persistentStorageKey:
        '${Uri.encodeComponent(config.url)}_autocomplete_cache_v1',
    persistentStaleDuration: const Duration(minutes: 5),
    autocomplete: (query) async {
      final dtos = await client.getAutocomplete(query: query.text);

      return dtos.map(parseHydrusAutocompleteData).toList();
    },
  );
});
