part of 'posts_provider.dart';

final postCountRepoProvider = Provider<PostCountRepository>((ref) {
  return PostCountRepositoryApi(
    api: ref.watch(danbooruApiProvider),
    //TODO: this is a hack to get around the fact that count endpoint includes all ratings
    extraTags: ref.watch(currentBooruProvider).booruType == BooruType.safebooru
        ? ['rating:general']
        : [],
  );
});

final postCountStateProvider =
    NotifierProvider<PostCountNotifier, PostCountState>(
  PostCountNotifier.new,
  dependencies: [
    postCountRepoProvider,
  ],
);

final postCountProvider = Provider<PostCountState>((ref) {
  return ref.watch(postCountStateProvider);
}, dependencies: [
  postCountStateProvider,
]);
