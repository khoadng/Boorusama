// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/tags/autocompletes/types.dart';

final gelbooruV1AutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>((ref, config) {
      final client = GelbooruClient.gelbooru();

      return AutocompleteRepositoryBuilder(
        autocomplete: (query) async {
          final dtos = await client.autocomplete(term: query.text);

          return dtos
              .map(
                (e) => AutocompleteData(
                  label: e.label ?? '<Unknown>',
                  value: e.value ?? '<Unknown>',
                ),
              )
              .toList();
        },
      );
    });
