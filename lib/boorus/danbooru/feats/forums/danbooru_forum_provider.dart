// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_infinite_scroll/riverpod_infinite_scroll.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/forums/forums.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';

final danbooruForumTopicRepoProvider =
    Provider.family<DanbooruForumTopicRepository, BooruConfig>((ref, config) {
  return DanbooruForumTopicRepositoryApi(
    client: ref.watch(danbooruClientProvider(config)),
  );
});

final danbooruForumTopicsProvider = StateNotifierProvider.autoDispose.family<
    DanbooruForumTopicsNotifier,
    PagedState<int, DanbooruForumTopic>,
    BooruConfig>((ref, config) {
  return DanbooruForumTopicsNotifier(
    repo: ref.watch(danbooruForumTopicRepoProvider(config)),
  );
});

final danbooruForumPostRepoProvider =
    Provider.family<DanbooruForumPostRepository, BooruConfig>((ref, config) {
  return DanbooruForumPostRepositoryApi(
    client: ref.watch(danbooruClientProvider(config)),
    onFetched: (posts) => ref
        .read(danbooruCreatorsProvider(config).notifier)
        .load(posts.expand((e) => e.votes).map((e) => e.creatorId).toList()),
  );
});

final danbooruForumPostsProvider = StateNotifierProvider.autoDispose.family<
    DanbooruForumPostsNotifier,
    PagedState<int, DanbooruForumPost>,
    int>((ref, topicId) {
  final config = ref.watch(currentBooruConfigProvider);
  return DanbooruForumPostsNotifier(
    topicId: topicId,
    repo: ref.watch(danbooruForumPostRepoProvider(config)),
  );
});
