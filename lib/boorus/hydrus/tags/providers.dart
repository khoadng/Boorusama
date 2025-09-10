// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/tags/autocompletes/types.dart';
import '../client_provider.dart';
import 'parser.dart';

final hydrusAutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>((ref, config) {
      final client = ref.watch(hydrusClientProvider(config));

      return AutocompleteRepositoryBuilder(
        autocomplete: (query) async {
          final dtos = await client.getAutocomplete(query: query.text);

          return dtos.map(parseHydrusAutocompleteData).toList();
        },
      );
    });
