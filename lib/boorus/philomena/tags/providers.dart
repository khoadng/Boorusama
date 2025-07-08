// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/tags/autocompletes/types.dart';
import '../client_provider.dart';
import 'parser.dart';

final philomenaAutoCompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>((ref, config) {
      final client = ref.watch(philomenaClientProvider(config));

      return AutocompleteRepositoryBuilder(
        persistentStorageKey:
            '${Uri.encodeComponent(config.url)}_autocomplete_cache_v2',
        autocomplete: (query) => switch (query.text.length) {
          0 || 1 => Future.value([]),
          _ =>
            client
                .getTags(query: '${query.text}*')
                .then(
                  (value) => value
                      .map(
                        parsePhilomenaTagToAutocompleteData,
                      )
                      .toList(),
                ),
        },
      );
    });
