part of 'posts_provider.dart';

final postCountRepoProvider = Provider<PostCountRepository>((ref) {
  final api = ref.watch(danbooruApiProvider);
  final currentBooruConfig = ref.watch(currentBooruConfigProvider);
  final currentBooru = ref.watch(currentBooruProvider);

  return PostCountRepositoryApi(
    api: api,
    booruConfig: currentBooruConfig,
    //TODO: this is a hack to get around the fact that count endpoint includes all ratings
    extraTags:
        currentBooru.booruType == BooruType.safebooru ? ['rating:general'] : [],
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
