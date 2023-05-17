// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/posts/posts.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/provider.dart';

final danbooruPostVoteRepoProvider = Provider<PostVoteRepository>(
  (ref) {
    final api = ref.watch(danbooruApiProvider);
    final currentBooruConfigRepository =
        ref.watch(currentBooruConfigRepoProvider);
    final booruUserIdentityProvider =
        ref.watch(booruUserIdentityProviderProvider);

    return PostVoteApiRepositoryApi(
      api: api,
      currentBooruConfigRepository: currentBooruConfigRepository,
      booruUserIdentityProvider: booruUserIdentityProvider,
    );
  },
  dependencies: [
    danbooruApiProvider,
    currentBooruConfigRepoProvider,
    booruUserIdentityProviderProvider,
  ],
);

final danbooruPostVotesProvider =
    NotifierProvider<PostVotesNotifier, Map<int, PostVote?>>(
  PostVotesNotifier.new,
  dependencies: [
    danbooruPostVoteRepoProvider,
    currentBooruConfigProvider,
  ],
);

final danbooruPostVoteProvider = Provider.autoDispose.family<PostVote?, int>(
  (ref, postId) => ref.watch(danbooruPostVotesProvider)[postId],
);
