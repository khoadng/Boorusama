// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config/types.dart';
import '../../../client_provider.dart';
import 'post_vote_repository.dart';
import 'post_vote_repository_api.dart';

final danbooruPostVoteRepoProvider =
    Provider.family<PostVoteRepository, BooruConfigAuth>(
      (ref, config) {
        return PostVoteApiRepositoryApi(
          client: ref.watch(danbooruClientProvider(config)),
        );
      },
    );
