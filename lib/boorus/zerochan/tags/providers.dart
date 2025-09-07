// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/tags/autocompletes/types.dart';
import '../../../core/tags/categories/tag_category.dart';
import '../../../core/tags/local/providers.dart';
import '../../../core/tags/tag/tag.dart';
import '../../../foundation/riverpod/riverpod.dart';
import '../client_provider.dart';
import 'parser.dart';

final zerochanAutoCompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>((ref, config) {
      final client = ref.watch(zerochanClientProvider(config));

      return AutocompleteRepositoryBuilder(
        persistentStorageKey:
            '${Uri.encodeComponent(config.url)}_autocomplete_cache_v3',
        persistentStaleDuration: const Duration(days: 1),
        autocomplete: (query) async {
          final tags = await client.getAutocomplete(
            query: query.text.toLowerCase(),
          );

          final data = tags
              .where(
                // Can't search posts by meta tags for some reason
                (e) => e.type != 'Meta',
              )
              .map(autocompleteDtoToAutocompleteData)
              .toList();

          if (data.isNotEmpty) {
            final tagCache = await ref.read(tagCacheRepositoryProvider.future);
            await tagCache.saveTagsBatchIfNeeded(
              tags: data.map(autocompleteDataToTag).toList(),
              siteHost: config.url,
            );
          }

          return data;
        },
      );
    });

final zerochanTagsFromIdProvider = FutureProvider.autoDispose
    .family<List<Tag>, (BooruConfigAuth, int)>(
      (ref, params) async {
        ref.cacheFor(const Duration(minutes: 1));

        final (config, id) = params;
        final client = ref.watch(zerochanClientProvider(config));

        final data = await client.getTagsFromPostId(postId: id);

        return data.where((e) => e.value != null).map(tagDtoToTag).toList();
      },
    );

final zerochanTagExtractorProvider =
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
            cachedTagMapper: const CachedTagMapper(),
            fetcher: (post, options, missing) async {
              // Get API tags
              final apiTags = await ref.read(
                zerochanTagsFromIdProvider((config, post.id)).future,
              );

              // Create normalized post tags
              final postTags = post.tags
                  .map((tagName) => Tag.noCount(
                        name: normalizeZerochanTag(tagName) ?? tagName,
                        category: TagCategory.unknown,
                      ))
                  .toList();

              // Get autocomplete data for missing tags
              final autocompleteTagMap = <String, Tag>{};
              await processTagsInChunks(
                missing: missing,
                normalizer: normalizeZerochanTag,
                fetcher: (tagName) async {
                  final results = await ref.read(zerochanAutoCompleteRepoProvider(config))
                      .getAutocomplete(AutocompleteQuery(text: tagName));
                  
                  if (results.isNotEmpty) {
                    final tag = autocompleteDataToTag(results.first);
                    autocompleteTagMap[tag.name] = tag;
                  }
                },
              );

              // Enhance post tags with autocomplete data
              final enhancedPostTags = postTags.map((tag) {
                return autocompleteTagMap[tag.name] ?? tag;
              }).toList();

              // Merge API tags with enhanced post tags (API takes priority)
              final allTagNames = <String>{};
              final combinedTags = <Tag>[];

              for (final tag in apiTags) {
                if (allTagNames.add(tag.name)) combinedTags.add(tag);
              }

              for (final tag in enhancedPostTags) {
                if (allTagNames.add(tag.name)) combinedTags.add(tag);
              }

              return combinedTags;
            },
          ),
        );
      },
    );
