// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/functional.dart';
import 'post_vote.dart';
import 'post_vote_repository.dart';
import 'post_vote_repository_api.dart';
import 'post_votes_notifier.dart';

final danbooruPostVoteRepoProvider = Provider<PostVoteRepository>(
  (ref) {
    return PostVoteApiRepositoryApi(
      client: ref.watch(danbooruClientProvider),
      booruConfig: ref.watch(currentBooruConfigProvider),
      booruUserIdentityProvider: ref.watch(booruUserIdentityProviderProvider),
    );
  },
  dependencies: [
    danbooruClientProvider,
    currentBooruConfigProvider,
    booruUserIdentityProviderProvider,
  ],
);

final danbooruPostVotesProvider =
    NotifierProvider<PostVotesNotifier, IMap<int, PostVote?>>(
  PostVotesNotifier.new,
  dependencies: [
    danbooruPostVoteRepoProvider,
    currentBooruConfigProvider,
  ],
);

final danbooruPostVoteProvider = Provider.autoDispose.family<PostVote?, int>(
  (ref, postId) => ref.watch(danbooruPostVotesProvider)[postId],
);
