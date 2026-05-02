// Package imports:
import 'package:booru_clients/nozomi.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/posts/post/types.dart';
import '../../../core/tags/autocompletes/types.dart';
import '../../../core/tags/categories/types.dart';
import '../../../core/tags/local/providers.dart';
import '../../../core/tags/local/types.dart';
import '../../../core/tags/tag/types.dart';
import '../client_provider.dart';
import '../posts/types.dart';
import 'parser.dart';

final nozomiAutocompleteRepoProvider =
    Provider.family<AutocompleteRepository, BooruConfigAuth>(
      (ref, config) {
        final client = ref.watch(nozomiClientProvider(config));
        final tagCache = ref.watch(tagCacheRepositoryProvider.future);

        return AutocompleteRepositoryBuilder(
          autocomplete: (query) async {
            final tags = await client.getAutocomplete(query: query.text);
            await _saveNozomiAutocompleteCounts(
              tagCache: tagCache,
              siteHost: config.url,
              tags: tags,
            );

            return tags.map(autocompleteDtoToAutocompleteData).toList();
          },
        );
      },
    );

final nozomiTagExtractorProvider =
    Provider.family<TagExtractor, BooruConfigAuth>(
      (ref, config) {
        final client = ref.watch(nozomiClientProvider(config));
        final tagCache = ref.watch(tagCacheRepositoryProvider.future);

        return TagExtractorBuilder(
          siteHost: config.url,
          tagCache: tagCache,
          sorter: TagSorter.defaults(),
          fetcher: (post, options) async {
            final counts = options.fetchTagCount && post is NozomiPost
                ? await _getNozomiTagCounts(
                    client: client,
                    tagCache: tagCache,
                    siteHost: config.url,
                    post: post,
                  )
                : const <String, int>{};

            return _extractNozomiTags(post, counts);
          },
        );
      },
    );

Future<Map<String, int>> _getNozomiTagCounts({
  required NozomiClient client,
  required Future<TagCacheRepository> tagCache,
  required String siteHost,
  required NozomiPost post,
}) async {
  final cache = await tagCache;
  final resolved = await cache.resolveTags(siteHost, post.tags.toList());
  final counts = <String, int>{
    for (final tag in resolved.found)
      if (tag.postCount case final int count) tag.tagName: count,
  };
  final unresolved = <String>{
    ...resolved.missing,
    ...resolved.found
        .where((tag) => tag.postCount == null || _isNozomiTagCacheStale(tag))
        .map((tag) => tag.tagName),
  };

  if (unresolved.isEmpty) return counts;

  final lookup = await client.resolveTagCounts(unresolved);
  final categories = _nozomiTagCategories(post);
  await cache.saveTagsBatch(
    [
      ...lookup.counts.entries.map(
        (entry) => TagInfo(
          siteHost: siteHost,
          tagName: entry.key,
          category: categories[entry.key]?.name ?? TagCategory.general().name,
          postCount: entry.value,
        ),
      ),
      ...lookup.missing.map(
        (tag) => TagInfo(
          siteHost: siteHost,
          tagName: tag,
          category: categories[tag]?.name ?? TagCategory.general().name,
          postCount: 0,
        ),
      ),
    ],
  );

  return {
    ...counts,
    ...lookup.counts,
  };
}

Future<void> _saveNozomiAutocompleteCounts({
  required Future<TagCacheRepository> tagCache,
  required String siteHost,
  required List<NozomiAutocompleteDto> tags,
}) async {
  if (tags.isEmpty) return;

  final cache = await tagCache;
  final resolved = await cache.resolveTags(
    siteHost,
    tags.map((tag) => tag.tag).toList(),
  );
  final categories = {
    for (final tag in resolved.found)
      if (tag.category.isNotEmpty) tag.tagName: tag.category,
  };

  await cache.saveTagsBatch(
    tags
        .map(
          (tag) => TagInfo(
            siteHost: siteHost,
            tagName: tag.tag,
            category: categories[tag.tag] ?? TagCategory.general().name,
            postCount: tag.postCount,
          ),
        )
        .toList(),
  );
}

bool _isNozomiTagCacheStale(CachedTag tag) {
  final updatedAt = tag.updatedAt;

  if (updatedAt == null) return true;

  final now = DateTime.now().toUtc();
  final interval = _getNozomiRefreshInterval(tag.postCount ?? 0);

  return now.difference(updatedAt.toUtc()) > interval;
}

Duration _getNozomiRefreshInterval(int postCount) {
  return switch (postCount) {
    0 || < 100 => const Duration(hours: 6),
    < 1000 => const Duration(days: 2),
    < 10000 => const Duration(days: 7),
    _ => const Duration(days: 30),
  };
}

List<Tag> _extractNozomiTags(Post post, Map<String, int> counts) {
  if (post is! NozomiPost) {
    return TagExtractor.extractTagsFromGenericPost(post);
  }

  final categorizedTags = <String>{
    ...post.artistTagSet,
    ...post.characterTagSet,
    ...post.copyrightTagSet,
  };
  final generalTags = post.tags.difference(categorizedTags);

  return [
    ...post.artistTagSet.map(
      (tag) => _nozomiTag(
        name: tag,
        category: TagCategory.artist(),
        counts: counts,
      ),
    ),
    ...post.copyrightTagSet.map(
      (tag) => _nozomiTag(
        name: tag,
        category: TagCategory.copyright(),
        counts: counts,
      ),
    ),
    ...post.characterTagSet.map(
      (tag) => _nozomiTag(
        name: tag,
        category: TagCategory.character(),
        counts: counts,
      ),
    ),
    ...generalTags.map(
      (tag) => _nozomiTag(
        name: tag,
        category: TagCategory.general(),
        counts: counts,
      ),
    ),
  ];
}

Map<String, TagCategory> _nozomiTagCategories(NozomiPost post) {
  final categorizedTags = <String>{
    ...post.artistTagSet,
    ...post.characterTagSet,
    ...post.copyrightTagSet,
  };

  return {
    for (final tag in post.artistTagSet) tag: TagCategory.artist(),
    for (final tag in post.copyrightTagSet) tag: TagCategory.copyright(),
    for (final tag in post.characterTagSet) tag: TagCategory.character(),
    for (final tag in post.tags.difference(categorizedTags))
      tag: TagCategory.general(),
  };
}

Tag _nozomiTag({
  required String name,
  required TagCategory category,
  required Map<String, int> counts,
}) {
  return Tag(
    name: name,
    category: category,
    postCount: counts[name] ?? 0,
  );
}
