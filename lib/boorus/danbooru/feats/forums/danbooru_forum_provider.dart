// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_infinite_scroll/riverpod_infinite_scroll.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/forums/forums.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';

final danbooruForumTopicRepoProvider =
    Provider<DanbooruForumTopicRepository>((ref) {
  return DanbooruForumTopicRepositoryApi(
    api: ref.watch(danbooruApiProvider),
  );
});

final danbooruForumTopicsProvider = StateNotifierProvider.autoDispose<
    DanbooruForumTopicsNotifier, PagedState<int, DanbooruForumTopic>>((ref) {
  return DanbooruForumTopicsNotifier(
    repo: ref.watch(danbooruForumTopicRepoProvider),
  );
});

final danbooruForumPostRepoProvider =
    Provider<DanbooruForumPostRepository>((ref) {
  return DanbooruForumPostRepositoryApi(
    api: ref.watch(danbooruApiProvider),
    onFetched: (posts) => ref
        .read(danbooruCreatorsProvider.notifier)
        .load(posts.expand((e) => e.votes).map((e) => e.creatorId).toList()),
  );
});

final danbooruForumPostsProvider = StateNotifierProvider.autoDispose.family<
        DanbooruForumPostsNotifier, PagedState<int, DanbooruForumPost>, int>(
    (ref, topicId) => DanbooruForumPostsNotifier(
          topicId: topicId,
          repo: ref.watch(danbooruForumPostRepoProvider),
        ));
