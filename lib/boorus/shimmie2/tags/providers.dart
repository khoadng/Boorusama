// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/tags/autocompletes/types.dart';
import '../client_provider.dart';

final shimmie2AutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>(
  (ref, config) {
    final client = ref.watch(shimmie2ClientProvider(config));

    return AutocompleteRepositoryBuilder(
      persistentStorageKey:
          '${Uri.encodeComponent(config.url)}_autocomplete_cache_v1',
      autocomplete: (query) async {
        final tags = await client.getAutocomplete(query: query.text);

        return tags
            .map(
              (e) => AutocompleteData(
                label: e.value?.toLowerCase().replaceAll('_', ' ') ?? '???',
                value: e.value?.toLowerCase() ?? '???',
                postCount: e.count,
              ),
            )
            .toList();
      },
    );
  },
);
