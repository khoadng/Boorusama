part of 'tags_provider.dart';

final danbooruRelatedTagRepProvider = Provider<RelatedTagRepository>((ref) {
  final api = ref.watch(danbooruApiProvider);

  return RelatedTagRepositoryApi(api);
});

final danbooruRelatedTagsProvider =
    NotifierProvider<RelatedTagsNotifier, IMap<String, RelatedTag>>(
  RelatedTagsNotifier.new,
);

final danbooruRelatedTagProvider = Provider.family<RelatedTag?, String>(
  (ref, tag) => ref.watch(danbooruRelatedTagsProvider)[tag],
);

final danbooruRelatedTagCosineSimilarityProvider =
    Provider.family<RelatedTag?, String>(
  (ref, tag) {
    final relatedTag = ref.watch(danbooruRelatedTagProvider(tag));

    if (relatedTag == null) return null;

    return relatedTag.copyWith(
      tags: relatedTag.tags
          .sorted((a, b) => b.cosineSimilarity.compareTo(a.cosineSimilarity)),
    );
  },
);
