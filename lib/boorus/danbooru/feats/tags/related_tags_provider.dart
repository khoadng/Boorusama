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
