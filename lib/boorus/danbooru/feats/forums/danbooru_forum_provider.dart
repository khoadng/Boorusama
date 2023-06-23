// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_infinite_scroll/riverpod_infinite_scroll.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/forums/forums.dart';
import 'danbooru_forum_topics_notifier.dart';

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
