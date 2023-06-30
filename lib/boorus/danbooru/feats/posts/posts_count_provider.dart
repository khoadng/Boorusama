part of 'posts_provider.dart';

final danbooruPostCountRepoProvider = Provider<PostCountRepository>((ref) {
  return PostCountRepositoryApi(
    api: ref.watch(danbooruApiProvider),
    //TODO: this is a hack to get around the fact that count endpoint includes all ratings
    extraTags: ref.watch(currentBooruProvider).booruType == BooruType.safebooru
        ? ['rating:general']
        : [],
  );
});
