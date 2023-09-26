// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';

final danbooruClientProvider = Provider<DanbooruClient>((ref) {
  final booruConfig = ref.watch(currentBooruConfigProvider);
  final dio = ref.watch(dioProvider(booruConfig.url));

  return DanbooruClient(
    dio: dio,
    baseUrl: booruConfig.url,
    login: booruConfig.login,
    apiKey: booruConfig.apiKey,
  );
});

final danbooruAutocompleteRepoProvider =
    Provider<AutocompleteRepository>((ref) {
  final client = ref.watch(danbooruClientProvider);

  return AutocompleteRepositoryBuilder(
      persistentStorageKey: 'danbooru_autocomplete_cache_v1',
      persistentStaleDuration: const Duration(days: 1),
      autocomplete: (query) async {
        final dtos = await client.autocomplete(query: query);

        return dtos
            .map((e) {
              try {
                if (AutocompleteData.isTagType(e.type)) {
                  return AutocompleteData(
                    type: e.type,
                    label: e.label!,
                    value: e.value!,
                    category: e.category?.toString(),
                    postCount: e.postCount,
                    antecedent: e.antecedent,
                  );
                } else if (e.type == AutocompleteData.pool) {
                  return AutocompleteData(
                    type: e.type,
                    label: e.label!,
                    value: e.value!,
                    category: e.category,
                    postCount: e.postCount,
                  );
                } else if (e.type == AutocompleteData.user) {
                  return AutocompleteData(
                    type: e.type,
                    label: e.label!,
                    value: e.value!,
                    level: e.level,
                  );
                } else {
                  return AutocompleteData(label: e.label!, value: e.value!);
                }
              } catch (err) {
                return AutocompleteData.empty;
              }
            })
            .where((e) => e != AutocompleteData.empty)
            .toList();
      });
});
