// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/tags/autocompletes/types.dart';
import '../../../core/tags/categories/types.dart';
import '../../../core/tags/local/providers.dart';
import '../../../core/tags/tag/types.dart';
import '../../../foundation/riverpod/riverpod.dart';
import '../client_provider.dart';

final sizebooruAutoCompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>((ref, config) {
      final client = ref.watch(sizebooruClientProvider(config));

      return AutocompleteRepositoryBuilder(
        autocomplete: (query) async {
          final results = await client.getAutocomplete(
            query: query.text.toLowerCase(),
          );

          return results
              .map(
                (e) => AutocompleteData(
                  label: e.label ?? e.value,
                  value: e.value,
                  postCount: e.postCount,
                ),
              )
              .toList();
        },
      );
    });

final sizebooruTagsFromIdProvider = FutureProvider.autoDispose
    .family<List<Tag>, (BooruConfigAuth, int)>(
      (ref, params) async {
        ref.cacheFor(const Duration(minutes: 1));

        final (config, id) = params;
        final client = ref.watch(sizebooruClientProvider(config));

        final tagNames = await client.getTagsFromPostId(id);

        return tagNames
            .map(
              (name) => Tag.noCount(
                name: name,
                category: TagCategory.general(),
              ),
            )
            .toList();
      },
    );

final sizebooruTagExtractorProvider =
    Provider.family<TagExtractor, BooruConfigAuth>(
      (ref, config) {
        return TagExtractorBuilder(
          siteHost: config.url,
          tagCache: ref.watch(tagCacheRepositoryProvider.future),
          sorter: TagSorter.defaults(),
          fetcher: (post, options) async {
            final tags = await ref.read(
              sizebooruTagsFromIdProvider((config, post.id)).future,
            );

            return tags;
          },
        );
      },
    );
