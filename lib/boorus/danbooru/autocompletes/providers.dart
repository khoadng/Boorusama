// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/autocompletes/autocompletes.dart';
import 'package:boorusama/core/configs.dart';
import '../danbooru_provider.dart';
import 'converter.dart';

final danbooruAutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>((ref, config) {
  final client = ref.watch(danbooruClientProvider(config));

  return AutocompleteRepositoryBuilder(
      persistentStorageKey:
          '${Uri.encodeComponent(config.url)}_autocomplete_cache_v1',
      persistentStaleDuration: const Duration(days: 1),
      autocomplete: (query) async {
        final dtos = await client.autocomplete(query: query);

        return dtos
            .map(convertAutocompleteDtoToData)
            .where((e) => e != AutocompleteData.empty)
            .toList();
      });
});
