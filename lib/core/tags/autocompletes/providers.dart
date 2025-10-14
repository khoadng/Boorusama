// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../boorus/engine/providers.dart';
import '../../configs/config/types.dart';
import 'autocomplete_repository.dart';

final autocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>(
      (ref, config) {
        final repo = ref
            .watch(booruEngineRegistryProvider)
            .getRepository(config.booruType);

        final autocompleteRepo = repo?.autocomplete(config);

        if (autocompleteRepo != null) {
          return autocompleteRepo;
        }

        return ref.watch(emptyAutocompleteRepoProvider);
      },
    );

final emptyAutocompleteRepoProvider = Provider<AutocompleteRepository>(
  (_) => EmptyAutocompleteRepository(),
);
