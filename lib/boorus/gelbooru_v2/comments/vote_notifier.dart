// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import 'providers.dart';

typedef GelbooruV2CommentVoteParams = ({
  BooruConfigAuth config,
  int postId,
  int commentId,
  int? initialScore,
});

enum CommentUpvoteResult {
  voted,
  alreadyVoted,
  loginRequired,
}

final gelbooruV2CommentVoteProvider = NotifierProvider.autoDispose
    .family<
      GelbooruV2CommentVoteNotifier,
      GelbooruV2CommentVoteState,
      GelbooruV2CommentVoteParams
    >(GelbooruV2CommentVoteNotifier.new);

class GelbooruV2CommentVoteState extends Equatable {
  const GelbooruV2CommentVoteState({
    required this.score,
    this.isSubmitting = false,
  });

  final int? score;
  final bool isSubmitting;

  @override
  List<Object?> get props => [score, isSubmitting];
}

class GelbooruV2CommentVoteNotifier
    extends
        AutoDisposeFamilyNotifier<
          GelbooruV2CommentVoteState,
          GelbooruV2CommentVoteParams
        > {
  CancelToken? _cancelToken;

  @override
  GelbooruV2CommentVoteState build(GelbooruV2CommentVoteParams arg) {
    ref.onDispose(() => _cancelToken?.cancel());
    return GelbooruV2CommentVoteState(score: arg.initialScore);
  }

  Future<CommentUpvoteResult?> upvote() async {
    if (state.isSubmitting) return null;

    final actionClient = ref.read(
      gelbooruV2CommentActionClientProvider(arg.config),
    );
    if (actionClient == null ||
        !actionClient.supports(gelbooruV2CommentUpvoteAction)) {
      throw StateError('Comment action is unavailable');
    }
    if (!actionClient.canInvoke(gelbooruV2CommentUpvoteAction)) {
      return CommentUpvoteResult.loginRequired;
    }

    final scoreBeforeRequest = state.score;
    state = GelbooruV2CommentVoteState(
      score: scoreBeforeRequest,
      isSubmitting: true,
    );

    final cancelToken = CancelToken();
    _cancelToken = cancelToken;

    try {
      final returnedScore = await actionClient.upvote(
        postId: arg.postId,
        commentId: arg.commentId,
        cancelToken: cancelToken,
      );
      if (cancelToken.isCancelled) return null;

      state = GelbooruV2CommentVoteState(score: returnedScore);

      return returnedScore == scoreBeforeRequest
          ? CommentUpvoteResult.alreadyVoted
          : CommentUpvoteResult.voted;
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) return null;

      state = GelbooruV2CommentVoteState(score: scoreBeforeRequest);
      rethrow;
    } catch (_) {
      if (!cancelToken.isCancelled) {
        state = GelbooruV2CommentVoteState(score: scoreBeforeRequest);
      }
      rethrow;
    } finally {
      if (identical(_cancelToken, cancelToken)) {
        _cancelToken = null;
      }
    }
  }
}
