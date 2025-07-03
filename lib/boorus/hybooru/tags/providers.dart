// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/tags/autocompletes/types.dart';
import '../client_provider.dart';
import 'parser.dart';

final hybooruAutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>(
  (ref, config) {
    final client = ref.watch(hybooruClientProvider(config));

    return AutocompleteRepositoryBuilder(
      persistentStorageKey:
          '${Uri.encodeComponent(config.url)}_autocomplete_cache_v1',
      autocomplete: (query) async {
        final tags = await client.getAutocomplete(query: query.text);

        return tags.map(autocompleteDtoToAutocompleteData).toList();
      },
    );
  },
);
