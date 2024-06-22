// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/functional.dart';
import 'post_vote.dart';
import 'post_vote_repository.dart';
import 'post_vote_repository_api.dart';
import 'post_votes_notifier.dart';

final danbooruPostVoteRepoProvider =
    Provider.family<PostVoteRepository, BooruConfig>(
  (ref, config) {
    return PostVoteApiRepositoryApi(
      client: ref.watch(danbooruClientProvider(config)),
      booruConfig: config,
    );
  },
  dependencies: [
    danbooruClientProvider,
    currentBooruConfigProvider,
  ],
);

final danbooruPostVotesProvider = NotifierProvider.family<PostVotesNotifier,
    IMap<int, PostVote?>, BooruConfig>(
  PostVotesNotifier.new,
  dependencies: [
    danbooruPostVoteRepoProvider,
    currentBooruConfigProvider,
  ],
);

final danbooruPostVoteProvider = Provider.autoDispose.family<PostVote?, int>(
  (ref, postId) {
    final config = ref.watchConfig;
    return ref.watch(danbooruPostVotesProvider(config))[postId];
  },
);
