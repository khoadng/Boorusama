// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/tags/autocompletes/types.dart';
import '../../../core/tags/local/providers.dart';
import '../../../core/tags/tag/providers.dart';
import '../../../core/tags/tag/types.dart';
import '../client_provider.dart';
import '../posts/types.dart';
import 'parser.dart';

const _kMaxTagsPerRequest = 50;

final e621TagRepoProvider = Provider.family<TagRepository, BooruConfigAuth>(
  (ref, config) {
    final client = ref.watch(e621ClientProvider(config));

    return TagRepositoryBuilder(
      getTags: (tags, page, {cancelToken}) async {
        final batches = <Future<List<Tag>>>[];
        for (var i = 0; i < tags.length; i += _kMaxTagsPerRequest) {
          final batch = tags.skip(i).take(_kMaxTagsPerRequest).toList();
          batches.add(
            client
                .getTagsByNames(
                  page: page,
                  tags: batch,
                  limit: _kMaxTagsPerRequest,
                  cancelToken: cancelToken,
                )
                .then((data) => data.map(e621TagDtoToTag).toList()),
          );
        }
        final results = await Future.wait(batches);
        return results.expand((x) => x).toList();
      },
    );
  },
);

final e621TagResolverProvider = Provider.family<TagResolver, BooruConfigAuth>((
  ref,
  config,
) {
  return TagResolver(
    tagCacheBuilder: () => ref.watch(tagCacheRepositoryProvider.future),
    siteHost: config.url,
    cachedTagMapper: CachedTagMapper(
      categoryMapper: (cachedTag) =>
          stringToE621TagCategory(cachedTag.category),
    ),
    tagRepositoryBuilder: () => ref.read(e621TagRepoProvider(config)),
  );
});

final e621TagExtractorProvider = Provider.family<TagExtractor, BooruConfigAuth>(
  (ref, config) {
    return TagExtractorBuilder(
      siteHost: config.url,
      tagCache: ref.watch(tagCacheRepositoryProvider.future),
      sorter: TagSorter.defaults(),
      artistCategory: e621ArtistTagCategory,
      characterCategory: e621CharacterTagCategory,
      fetcher: (post, options) {
        final tagResolver = ref.read(e621TagResolverProvider(config));

        if (post case final E621Post e621Post) {
          final tags = _extractTagsFromPost(e621Post);

          if (!options.fetchTagCount) {
            return tags;
          }

          return tagResolver.resolvePartialTags(tags);
        } else {
          return tagResolver.resolveRawTags(post.tags);
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
