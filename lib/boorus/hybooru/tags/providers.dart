// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/tags/autocompletes/types.dart';
import '../../../core/tags/local/providers.dart';
import '../../../core/tags/tag/types.dart';
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
        final tagCache = ref.watch(tagCacheRepositoryProvider.future);
        return TagExtractorBuilder(
          siteHost: config.url,
          tagCache: tagCache,
          sorter: TagSorter.defaults(),
          fetcher: createCachedTagFetcher(
            siteHost: config.url,
            tagCache: tagCache,
            cachePolicy: CachePolicy.aMonth(),
            cachedTagMapper: const CachedTagMapper(),
            fetcher: (post, options, missing) async {
              final tags = await ref.read(
                hybooruTagsFromIdProvider((config, post.id)).future,
              );

              return tags;
            },
          ),
        );
      },
    );

final hybooruAutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>(
      (ref, config) {
        final client = ref.watch(hybooruClientProvider(config));

        return AutocompleteRepositoryBuilder(
          autocomplete: (query) async {
            final tags = await client.getAutocomplete(query: query.text);

            return tags.map(autocompleteDtoToAutocompleteData).toList();
          },
        );
      },
    );
