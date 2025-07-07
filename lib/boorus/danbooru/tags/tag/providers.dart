// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/configs/config.dart';
import '../../../../core/tags/categories/tag_category.dart';
import '../../../../core/tags/tag/providers.dart';
import '../../../../core/tags/tag/tag.dart';
import '../../client_provider.dart';
import '../../posts/post/post.dart';

final danbooruTagRepoProvider = Provider.family<TagRepository, BooruConfigAuth>(
  (ref, config) {
    final client = ref.watch(danbooruClientProvider(config));

    return TagRepositoryBuilder(
      persistentStorageKey: '${Uri.encodeComponent(config.url)}_tags_cache_v1',
      getTags: (tags, page, {cancelToken}) async {
        final data = await client.getTagsByName(
          page: page,
          hideEmpty: true,
          tags: tags,
          cancelToken: cancelToken,
        );

        return data
            .map(
              (d) => Tag(
                name: d.name ?? '',
                category: TagCategory.fromLegacyId(d.category ?? 0),
                postCount: d.postCount ?? 0,
              ),
            )
            .toList();
      },
    );
  },
);

final danbooruTagExtractorProvider =
    Provider.family<TagExtractor<DanbooruPost>, BooruConfigAuth>(
      (ref, config) {
        return TagExtractorBuilder(
          sorter: TagSorter.defaults(),
          fetcher: (post, options) {
            // Use read to avoid circular dependency
            final tagResolver = ref.read(tagResolverProvider(config));

            if (post case final DanbooruPost danbooruPost) {
              final tags = _extractTagsFromPost(danbooruPost);

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

List<Tag> _extractTagsFromPost(DanbooruPost post) {
  final tags = <Tag>[];

  for (final t in post.artistTags) {
    tags.add(
      Tag.noCount(
        name: t,
        category: TagCategory.artist(),
      ),
    );
  }

  for (final t in post.copyrightTags) {
    tags.add(
      Tag.noCount(
        name: t,
        category: TagCategory.copyright(),
      ),
    );
  }

  for (final t in post.characterTags) {
    tags.add(
      Tag.noCount(
        name: t,
        category: TagCategory.character(),
      ),
    );
  }

  for (final t in post.metaTags) {
    tags.add(
      Tag.noCount(
        name: t,
        category: TagCategory.meta(),
      ),
    );
  }

  for (final t in post.generalTags) {
    tags.add(
      Tag.noCount(
        name: t,
        category: TagCategory.general(),
      ),
    );
  }

  return tags;
}
