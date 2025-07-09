// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/tags/autocompletes/types.dart';
import '../../../core/tags/tag/tag.dart';
import '../../../foundation/riverpod/riverpod.dart';
import '../client_provider.dart';
import 'parser.dart';

final hybooruTagsFromIdProvider = FutureProvider.autoDispose
    .family<List<Tag>, (BooruConfigAuth, int)>(
      (ref, params) async {
        ref.cacheFor(const Duration(minutes: 5));

        final (config, id) = params;
        final client = ref.watch(hybooruClientProvider(config));

        final data = await client.getTagsFromPostId(postId: id);

        return data.map(tagDtoToTag).toList();
      },
    );

final hybooruTagExtractorProvider =
    Provider.family<TagExtractor, BooruConfigAuth>(
      (ref, config) {
        return TagExtractorBuilder(
          sorter: TagSorter.defaults(),
          fetcher: (post, options) async {
            final tags = await ref.read(
              hybooruTagsFromIdProvider((config, post.id)).future,
            );

            return tags;
          },
        );
      },
    );

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
