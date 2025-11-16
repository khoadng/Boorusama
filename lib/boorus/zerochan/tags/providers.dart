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
import 'parser.dart';

final zerochanAutoCompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>((ref, config) {
      final client = ref.watch(zerochanClientProvider(config));

      return AutocompleteRepositoryBuilder(
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
              .nonNulls
              .toList();

          if (data.isNotEmpty) {
            final tagCache = await ref.read(tagCacheRepositoryProvider.future);
            await tagCache.saveTagsBatchIfNeeded(
              tags: data.map(autocompleteDataToTag).nonNulls.toList(),
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

        return data
            .where((e) => e.value != null)
            .map(tagDtoToTag)
            .nonNulls
            .toList();
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
            normalizer: (tags) => tags.map(normalizeZerochanTag).toSet(),
            cachedTagMapper: const CachedTagMapper(),
            fetcher: (post, options, missing) async {
              final apiTags = await ref.read(
                zerochanTagsFromIdProvider((config, post.id)).future,
              );

              final postTags = post.tags
                  .map(
                    (tagName) => Tag.noCount(
                      name: normalizeZerochanTag(tagName),
                      category: TagCategory.unknown,
                    ),
                  )
                  .toList();

              final autocompleteTagMap = <String, Tag>{};
              await processTagsInChunks(
                missing: missing,
                normalizer: normalizeZerochanTag,
                fetcher: (tagName) async {
                  final results = await ref
                      .read(zerochanAutoCompleteRepoProvider(config))
                      .getAutocomplete(AutocompleteQuery(text: tagName));

                  final result = results.firstOrNull;
                  if (result == null) return;

                  final tag = autocompleteDataToTag(result);
                  if (tag == null) return;
                  autocompleteTagMap[tag.name] = tag;
                },
              );

              final enhancedPostTags = postTags.map((tag) {
                return autocompleteTagMap[tag.name] ?? tag;
              }).toList();

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
