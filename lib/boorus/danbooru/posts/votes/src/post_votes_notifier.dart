// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../core/configs/auth/types.dart';
import '../../../../../core/configs/config/providers.dart';
import '../../../../../core/configs/config/types.dart';
import '../../../../../core/posts/votes/providers.dart';
import '../../../../../core/posts/votes/types.dart';
import '../../../users/user/providers.dart';
import '../../post/types.dart';
import 'post_vote.dart';
import 'post_vote_repository.dart';
import 'providers.dart';
import 'removable_vote_id.dart';

final danbooruPostVotesProvider =
    NotifierProvider.family<
      PostVotesNotifier,
      IMap<int, DanbooruPostVote?>,
      BooruConfigAuth
    >(
      PostVotesNotifier.new,
    );

final danbooruPostVoteProvider = Provider.autoDispose
    .family<DanbooruPostVote?, (BooruConfigAuth, int)>(
      (ref, params) {
        final (config, postId) = params;
        return ref.watch(danbooruPostVotesProvider(config))[postId];
      },
    );

class PostVotesNotifier
    extends FamilyNotifier<IMap<int, DanbooruPostVote?>, BooruConfigAuth> {
  @override
  IMap<int, DanbooruPostVote?> build(BooruConfigAuth arg) {
    return <int, DanbooruPostVote?>{}.lock;
  }

  PostVoteRepository get repo => ref.read(danbooruPostVoteRepoProvider(arg));

  Future<void> upvote(int postId, {bool localOnly = false}) async {
    final vote = localOnly
        ? DanbooruPostVote.local(postId: postId, score: 1)
        : await repo.upvote(postId);

    state = VotesStateHelpers.updateVote(state, vote);
  }

  Future<void> downvote(int postId, {bool localOnly = false}) async {
    final vote = localOnly
        ? DanbooruPostVote.local(postId: postId, score: -1)
        : await repo.downvote(postId);

    state = VotesStateHelpers.updateVote(state, vote);
  }

  void removeLocalVote(int postId) {
    state = VotesStateHelpers.removeVoteFromState(state, postId);
  }

  Future<bool> removeVote(
    int postId,
    PostVoteId? voteId,
  ) async {
    final removableVoteId = switch (voteId) {
      null => await _lookupVoteId(postId),
      final id when DanbooruPostVote.isLocalVote(id) => await _lookupVoteId(
        postId,
      ),
      final id => FoundVoteId(id),
    };

    return switch (removableVoteId) {
      FoundVoteId(:final voteId) => await _removeVoteAndUpdateState(
        postId,
        voteId,
      ),
      VoteNotFound() || NoVoteToRemove() => false,
    };
  }

  Future<RemovableVoteId> _lookupVoteId(int postId) async {
    final user = await ref.read(danbooruCurrentUserProvider(arg).future);
    if (user == null) return const NoVoteToRemove();

    final currentVoteState = state[postId]?.voteState;
    final userVotes = await repo.getPostVotesFromUser([postId], user.id);

    return RemovableVoteId.fromUserVotes(currentVoteState, userVotes);
  }

  Future<bool> _removeVoteAndUpdateState(int postId, PostVoteId voteId) async {
    final success = await repo.removeVote(voteId);
    if (success) {
      removeLocalVote(postId);
    }
    return success;
  }

  Future<void> getVotes(List<DanbooruPost> posts) async {
    final user = await ref.read(danbooruCurrentUserProvider(arg).future);
    if (user == null) return;

    final postIds = posts.map((e) => e.id).toList();
    final postIdsToFetch = VotesStateHelpers.filterPostIdsNeedingFetch(
      state,
      postIds,
    );

    if (postIdsToFetch.isEmpty) return;

    final fetchedVotes = await repo.getPostVotesFromUser(postIds, user.id);
    state = VotesStateHelpers.mergeVotesIntoState(state, postIds, fetchedVotes);
  }
}

extension DanbooruVoteX on WidgetRef {
  void danbooruRemoveVote(
    int postId,
    PostVoteId id,
  ) {
    guardLogin(this, () async {
      final success = await read(
        danbooruPostVotesProvider(readConfigAuth).notifier,
      ).removeVote(postId, id);

      if (context.mounted) {
        if (success) {
          showSuccessSnackBar(
            context,
            'Vote removed',
          );
        } else {
          showSuccessSnackBar(
            context,
            'Failed to remove vote',
          );
        }
      }
    });
  }

  void danbooruUpvote(int postId) {
    guardLogin(this, () async {
      await read(
        danbooruPostVotesProvider(readConfigAuth).notifier,
      ).upvote(postId);

      if (context.mounted) {
        showSuccessSnackBar(
          context,
          'Upvoted',
        );
      }
    });
  }

  void danbooruDownvote(int postId) {
    guardLogin(this, () async {
      await read(
        danbooruPostVotesProvider(readConfigAuth).notifier,
      ).downvote(postId);

      if (context.mounted) {
        showSuccessSnackBar(
          context,
          'Downvoted',
        );
      }
    });
  }
}
