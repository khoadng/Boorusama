part of 'tags_provider.dart';

final danbooruRelatedTagRepProvider = Provider<RelatedTagRepository>((ref) {
  final api = ref.watch(danbooruApiProvider);

  return RelatedTagRepositoryApi(api);
});

final danbooruRelatedTagsProvider =
    NotifierProvider<RelatedTagsNotifier, Map<String, RelatedTag>>(
  RelatedTagsNotifier.new,
);
