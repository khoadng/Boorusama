// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/search/queries/query.dart';
import '../../../core/tags/autocompletes/types.dart';
import '../../../core/tags/local/providers.dart';
import '../../../core/tags/tag/providers.dart';
import '../../../core/tags/tag/tag.dart';
import '../client_provider.dart';
import 'parser.dart';
import 'query_composer.dart';

final gelbooruTagRepoProvider = Provider.family<TagRepository, BooruConfigAuth>(
  (ref, config) {
    final client = ref.watch(gelbooruClientProvider(config));

    return TagRepositoryBuilder(
      getTags: (tags, page, {cancelToken}) async {
        final data = await client.getTags(
          page: page,
          tags: tags,
        );

        return data.map(gelbooruTagDtoToTag).toList();
      },
    );
  },
);

final gelbooruTagQueryComposerProvider =
    Provider.family<TagQueryComposer, BooruConfigSearch>(
      (ref, config) => GelbooruTagQueryComposer(config: config),
    );

final gelbooruTagResolverProvider =
    Provider.family<TagResolver, BooruConfigAuth>((ref, config) {
      return TagResolver(
        tagCacheBuilder: () => ref.watch(tagCacheRepositoryProvider.future),
        siteHost: config.url,
        cachedTagMapper: const CachedTagMapper(),
        tagRepositoryBuilder: () => ref.read(gelbooruTagRepoProvider(config)),
      );
    });

final invalidTags = [
  ':&lt;',
];

final gelbooruTagExtractorProvider =
    Provider.family<TagExtractor, BooruConfigAuth>(
      (ref, config) {
        return TagExtractorBuilder(
          siteHost: config.url,
          tagCache: ref.watch(tagCacheRepositoryProvider.future),
          sorter: TagSorter.defaults(),
          fetcher: (post, options) async {
            final tagResolver = ref.read(gelbooruTagResolverProvider(config));

            final tagList = post.tags;

            // filter tagList to remove invalid tags
            final filtered = tagList
                .where((e) => !invalidTags.contains(e))
                .toSet();

            if (filtered.isEmpty) return const [];

            final tags = await tagResolver.resolveRawTags(filtered);

            return tags;
          },
        );
      },
    );

final gelbooruAutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>((ref, config) {
      final client = ref.watch(gelbooruClientProvider(config));

      return AutocompleteRepositoryBuilder(
        autocomplete: (query) async {
          final dtos = await client.autocomplete(term: query.text, limit: 20);

          return dtos
              .map(autocompleteDtoToAutocompleteData)
              .where((e) => e != AutocompleteData.empty)
              .toList();
        },
        persistentStorageKey:
            '${Uri.encodeComponent(config.url)}_autocomplete_cache_v1',
      );
    });
