part of 'posts_provider.dart';

final danbooruPostCountRepoProvider = Provider<PostCountRepository>((ref) {
  return PostCountRepositoryApi(
    client: ref.watch(danbooruClientProvider),
    //TODO: this is a hack to get around the fact that count endpoint includes all ratings
    extraTags: ref.watch(currentBooruConfigProvider).url == kDanbooruSafeUrl
        ? ['rating:general']
        : [],
  );
});
