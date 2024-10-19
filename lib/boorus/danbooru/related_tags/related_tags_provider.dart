// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/clients/danbooru/types/types.dart' as danbooru;
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'related_tags.dart';

const _kTagLimit = 300;

final danbooruRelatedTagRepProvider =
    Provider.family<RelatedTagRepository, BooruConfig>((ref, config) {
  final client = ref.watch(danbooruClientProvider(config));

  return RelatedTagRepositoryBuilder(
    fetch: (query, {category, order, limit}) async {
      final related = await client
          .getRelatedTag(
            query: query,
            category: _toDanbooruTagCategory(category),
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
          .catchError((obj) => const DanbooruRelatedTag.empty());

      await ref
          .read(booruTagTypeStoreProvider)
          .saveRelatedTagIfNotExist(config.booruType, related);

      return related;
    },
  );
});

final danbooruRelatedTagProvider = FutureProvider.autoDispose
    .family<DanbooruRelatedTag, String>((ref, tag) async {
  if (tag.isEmpty) return const DanbooruRelatedTag.empty();

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

    tags.sort(
        (a, b) => (a.category.order ?? 0).compareTo(b.category.order ?? 0));

    return tags;
  },
);

danbooru.TagCategory? _toDanbooruTagCategory(TagCategory? category) {
  if (category == TagCategory.artist()) return danbooru.TagCategory.artist;
  if (category == TagCategory.copyright()) {
    return danbooru.TagCategory.copyright;
  }
  if (category == TagCategory.character()) {
    return danbooru.TagCategory.character;
  }
  if (category == TagCategory.general()) {
    return danbooru.TagCategory.general;
  }
  if (category == TagCategory.meta()) {
    return danbooru.TagCategory.meta;
  }

  return null;
}

DanbooruRelatedTag relatedTagDtoToRelatedTag(danbooru.RelatedTagDto dto) =>
    DanbooruRelatedTag(
      query: dto.query ?? '',
      wikiPageTags: dto.wikiPageTags
              ?.map((e) => Tag(
                    name: e.name ?? '',
                    category: TagCategory.fromLegacyId(e.category),
                    postCount: e.postCount ?? 0,
                  ))
              .toList() ??
          [],
      tags: dto.relatedTags != null
          ? dto.relatedTags!
              .map((e) => DanbooruRelatedTagItem(
                    tag: e.tag?.name ?? '',
                    category: TagCategory.fromLegacyId(e.tag?.category),
                    jaccardSimilarity: e.jaccardSimilarity ?? 0.0,
                    cosineSimilarity: e.cosineSimilarity ?? 0.0,
                    overlapCoefficient: e.overlapCoefficient ?? 0.0,
                    frequency: e.frequency ?? 0,
                    postCount: e.tag?.postCount ?? 0,
                  ))
              .toList()
          : [],
    );

extension BooruTagTypeStoreX on BooruTagTypeStore {
  Future<void> saveRelatedTagIfNotExist(
    BooruType booruType,
    DanbooruRelatedTag related,
  ) =>
      saveIfNotExist(
        booruType,
        related.tags,
        (tag) => tag.tag,
        (tag) => tag.category.name,
      );
}
