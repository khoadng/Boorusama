// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/posts/votes/src/post_vote_repository.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/configs/current.dart';
import 'post_vote_repository_api.dart';

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
