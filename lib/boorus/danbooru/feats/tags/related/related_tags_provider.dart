// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/clients/danbooru/types/types.dart' as danbooru;
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/tags/tags.dart';

const _kTagLimit = 300;

final danbooruRelatedTagRepProvider =
    Provider.family<RelatedTagRepository, BooruConfig>((ref, config) {
  final client = ref.watch(danbooruClientProvider(config));

  return RelatedTagRepositoryBuilder(
    fetch: (query, {category, order, limit}) async {
      final related = await client
          .getRelatedTag(
            query: query,
            category: switch (category) {
              TagCategory.artist => danbooru.TagCategory.artist,
              TagCategory.character => danbooru.TagCategory.character,
              TagCategory.general => danbooru.TagCategory.general,
              TagCategory.copyright => danbooru.TagCategory.copyright,
              TagCategory.meta => danbooru.TagCategory.meta,
              TagCategory.invalid_ => null,
              null => null,
            },
            order: switch (order) {
              RelatedType.cosine => danbooru.RelatedType.cosine,
              RelatedType.jaccard => danbooru.RelatedType.jaccard,
              RelatedType.overlap => danbooru.RelatedType.overlap,
              RelatedType.frequency => danbooru.RelatedType.frequency,
              null => null,
            },
            limit: limit ?? _kTagLimit,
          )
          .then(relatedTagDtoToRelatedTag)
          .catchError((obj) => const RelatedTag.empty());

      await ref
          .read(booruTagTypeStoreProvider)
          .saveRelatedTagIfNotExist(config.booruType, related);

      return related;
    },
  );
});

final danbooruRelatedTagProvider =
    FutureProvider.autoDispose.family<RelatedTag, String>((ref, tag) async {
  if (tag.isEmpty) return const RelatedTag.empty();

  final config = ref.watchConfig;

  final repo = ref.watch(danbooruRelatedTagRepProvider(config));
  final relatedTag = await repo.getRelatedTag(tag);

  return relatedTag;
});

final danbooruWikiTagsProvider = FutureProvider.family<List<Tag>, String>(
  (ref, tag) async {
    if (tag.isEmpty) return [];
    final config = ref.watchConfig;

    final related = await ref
        .watch(danbooruRelatedTagRepProvider(config))
        .getRelatedTag(tag, limit: 20);

    await ref
        .read(booruTagTypeStoreProvider)
        .saveTagIfNotExist(config.booruType, related.wikiPageTags);

    return related.wikiPageTags;
  },
);

final danbooruRelatedTagsProvider = FutureProvider.family<List<Tag>, String>(
  (ref, tag) async {
    if (tag.isEmpty) return [];

    final repo = ref.watch(danbooruRelatedTagRepProvider(ref.watchConfig));
    final related = await repo.getRelatedTag(tag, limit: 30);

    final tags = related.tags
        .map((e) =>
            Tag(name: e.tag, category: e.category, postCount: e.postCount))
        .toList();

    tags.sort((a, b) => _tagCategoryToOrder(a.category)
        .compareTo(_tagCategoryToOrder(b.category)));

    return tags;
  },
);

int _tagCategoryToOrder(TagCategory category) => switch (category) {
      TagCategory.artist => 0,
      TagCategory.copyright => 1,
      TagCategory.character => 2,
      TagCategory.general => 3,
      TagCategory.meta => 4,
      TagCategory.invalid_ => 5,
    };

RelatedTag relatedTagDtoToRelatedTag(danbooru.RelatedTagDto dto) => RelatedTag(
      query: dto.query ?? '',
      wikiPageTags: dto.wikiPageTags
              ?.map((e) => Tag(
                    name: e.name ?? '',
                    category: intToTagCategory(e.category),
                    postCount: e.postCount ?? 0,
                  ))
              .toList() ??
          [],
      tags: dto.relatedTags != null
          ? dto.relatedTags!
              .map((e) => RelatedTagItem(
                    tag: e.tag?.name ?? '',
                    category: intToTagCategory(e.tag?.category ?? 0),
                    jaccardSimilarity: e.jaccardSimilarity ?? 0.0,
                    cosineSimilarity: e.cosineSimilarity ?? 0.0,
                    overlapCoefficient: e.overlapCoefficient ?? 0.0,
                    frequency: e.frequency ?? 0,
                    postCount: e.tag?.postCount ?? 0,
                  ))
              .toList()
          : [],
    );
