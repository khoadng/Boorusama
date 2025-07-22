// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/tags/autocompletes/types.dart';
import '../../../core/tags/local/providers.dart';
import '../../../core/tags/tag/providers.dart';
import '../../../core/tags/tag/tag.dart';
import '../client_provider.dart';
import '../posts/types.dart';
import 'parser.dart';

final e621TagRepoProvider = Provider.family<TagRepository, BooruConfigAuth>(
  (ref, config) {
    final client = ref.watch(e621ClientProvider(config));

    return TagRepositoryBuilder(
      persistentStorageKey: '${Uri.encodeComponent(config.url)}_tags_cache_v1',
      getTags: (tags, page, {cancelToken}) async {
        final data = await client.getTagsByNames(
          page: page,
          tags: tags.toList(),
        );

        return data.map(e621TagDtoToTag).toList();
      },
    );
  },
);

final e621TagExtractorProvider =
    Provider.family<TagExtractor<E621Post>, BooruConfigAuth>(
      (ref, config) {
        return TagExtractorBuilder(
          siteHost: config.url,
          tagCache: ref.watch(tagCacheRepositoryProvider.future),
          sorter: TagSorter.defaults(),
          fetcher: (post, options) {
            // Use read to avoid circular dependency
            final tagResolver = ref.read(tagResolverProvider(config));

            if (post case final E621Post e621Post) {
              final tags = _extractTagsFromPost(e621Post);

              if (!options.fetchTagCount) {
                return tags;
              }

              return tagResolver.resolvePartialTags(tags);
            } else {
              return TagExtractor.extractTagsFromGenericPost(post);
            }
          },
        );
      },
    );

List<Tag> _extractTagsFromPost(E621Post post) {
  return [
    ...post.artistTags.map(
      (e) => Tag.noCount(
        name: e,
        category: e621ArtistTagCategory,
      ),
    ),
    ...post.characterTags.map(
      (e) => Tag.noCount(
        name: e,
        category: e621CharacterTagCategory,
      ),
    ),
    ...post.speciesTags.map(
      (e) => Tag.noCount(
        name: e,
        category: e621SpeciesTagCategory,
      ),
    ),
    ...post.copyrightTags.map(
      (e) => Tag.noCount(
        name: e,
        category: e621CopyrightTagCategory,
      ),
    ),
    ...post.generalTags.map(
      (e) => Tag.noCount(
        name: e,
        category: e621GeneralTagCategory,
      ),
    ),
    ...post.metaTags.map(
      (e) => Tag.noCount(
        name: e,
        category: e621MetaTagCagegory,
      ),
    ),
    ...post.loreTags.map(
      (e) => Tag.noCount(
        name: e,
        category: e621LoreTagCategory,
      ),
    ),
  ];
}

final e621AutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>((ref, config) {
      final client = ref.watch(e621ClientProvider(config));

      return AutocompleteRepositoryBuilder(
        persistentStorageKey:
            '${Uri.encodeComponent(config.url)}_autocomplete_cache_v1',
        persistentStaleDuration: const Duration(days: 1),
        autocomplete: (query) async {
          final dtos = await client.getAutocomplete(query: query.text);

          return dtos
              .map(
                (e) => AutocompleteData(
                  type: AutocompleteData.tag,
                  label: e.name?.replaceAll('_', ' ') ?? '',
                  value: e.name ?? '',
                  category: intToE621TagCategory(e.category).name,
                  postCount: e.postCount,
                  antecedent: e.antecedentName,
                ),
              )
              .toList();
        },
      );
    });
