// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/functional.dart';
import 'danbooru_post_vote.dart';
import 'post_vote_repository.dart';
import 'post_vote_repository_api.dart';
import 'post_votes_notifier.dart';

final danbooruPostVoteRepoProvider =
    Provider.family<PostVoteRepository, BooruConfigAuth>(
  (ref, config) {
    return PostVoteApiRepositoryApi(
      client: ref.watch(danbooruClientProvider(config)),
      authConfig: config,
    );
  },
  dependencies: [
    danbooruClientProvider,
    currentBooruConfigProvider,
  ],
);

final danbooruPostVotesProvider = NotifierProvider.family<PostVotesNotifier,
    IMap<int, DanbooruPostVote?>, BooruConfigAuth>(
  PostVotesNotifier.new,
  dependencies: [
    danbooruPostVoteRepoProvider,
    currentBooruConfigProvider,
  ],
);

final danbooruPostVoteProvider =
    Provider.autoDispose.family<DanbooruPostVote?, int>(
  (ref, postId) {
    final config = ref.watchConfigAuth;
    return ref.watch(danbooruPostVotesProvider(config))[postId];
  },
);
