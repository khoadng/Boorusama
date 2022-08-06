// Package imports:
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/users/user.dart';

class MockPostVoteRepository extends Mock implements PostVoteRepository {}

PostVote postVote(int score) => PostVote(
      id: 0,
      postId: 0,
      userId: const UserId(0),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      score: score,
      isDeleted: false,
    );

void main() {
  final postVoteRepo = MockPostVoteRepository();

  group('[upvote]', () {
    blocTest<PostVoteBloc, PostVoteState>(
      'if vote state is unvote, increase score by 1, increase up score by 1, change vote state to upvoted',
      setUp: () {
        when(() => postVoteRepo.upvote(any()))
            .thenAnswer((_) async => postVote(1));
        when(() => postVoteRepo.getPostVotes(any()))
            .thenAnswer((_) async => []);
      },
      tearDown: () => reset(postVoteRepo),
      seed: () => const PostVoteState(
        status: LoadStatus.success,
        score: 0,
        upScore: 2,
        downScore: -2,
        state: VoteState.unvote,
      ),
      build: () => PostVoteBloc(
        postVoteRepository: postVoteRepo,
      ),
      act: (bloc) => bloc.add(const PostVoteUpvoted(postId: 1)),
      expect: () => [
        const PostVoteState(
          status: LoadStatus.loading,
          score: 0,
          upScore: 2,
          downScore: -2,
          state: VoteState.unvote,
        ),
        const PostVoteState(
          status: LoadStatus.success,
          score: 1,
          upScore: 3,
          downScore: -2,
          state: VoteState.upvoted,
        ),
      ],
    );

    blocTest<PostVoteBloc, PostVoteState>(
      'if vote state is upvoted, do nothing',
      setUp: () {
        when(() => postVoteRepo.upvote(any()))
            .thenAnswer((_) async => postVote(1));
      },
      tearDown: () => reset(postVoteRepo),
      seed: () => const PostVoteState(
        status: LoadStatus.success,
        score: 0,
        upScore: 2,
        downScore: -2,
        state: VoteState.upvoted,
      ),
      build: () => PostVoteBloc(
        postVoteRepository: postVoteRepo,
      ),
      act: (bloc) => bloc.add(const PostVoteUpvoted(postId: 1)),
      expect: () => [],
    );

    blocTest<PostVoteBloc, PostVoteState>(
      'if vote state is downvoted, increase score by 2, increase up score by 1, decrease down score by 1, change vote state to upvoted',
      setUp: () {
        when(() => postVoteRepo.upvote(any()))
            .thenAnswer((_) async => postVote(1));
      },
      seed: () => const PostVoteState(
        status: LoadStatus.success,
        score: 2,
        upScore: 3,
        downScore: -1,
        state: VoteState.downvoted,
      ),
      build: () => PostVoteBloc(postVoteRepository: postVoteRepo),
      act: (bloc) => bloc.add(const PostVoteUpvoted(postId: 1)),
      expect: () => [
        const PostVoteState(
          status: LoadStatus.loading,
          score: 2,
          upScore: 3,
          downScore: -1,
          state: VoteState.downvoted,
        ),
        const PostVoteState(
          status: LoadStatus.success,
          score: 4,
          upScore: 4,
          downScore: 0,
          state: VoteState.upvoted,
        ),
      ],
    );
  });

  group('[downvote]', () {
    blocTest<PostVoteBloc, PostVoteState>(
      'decrease score by 1, decrease down score by 1, change vote state to downvoted',
      setUp: () {
        when(() => postVoteRepo.downvote(any()))
            .thenAnswer((_) async => postVote(1));
        when(() => postVoteRepo.getPostVotes(any()))
            .thenAnswer((_) async => []);
      },
      tearDown: () => reset(postVoteRepo),
      seed: () => const PostVoteState(
        status: LoadStatus.success,
        score: 0,
        upScore: 2,
        downScore: -2,
        state: VoteState.unvote,
      ),
      build: () => PostVoteBloc(
        postVoteRepository: postVoteRepo,
      ),
      act: (bloc) => bloc.add(const PostVoteDownvoted(postId: 1)),
      expect: () => [
        const PostVoteState(
          status: LoadStatus.loading,
          score: 0,
          upScore: 2,
          downScore: -2,
          state: VoteState.unvote,
        ),
        const PostVoteState(
          status: LoadStatus.success,
          score: -1,
          upScore: 2,
          downScore: -3,
          state: VoteState.downvoted,
        ),
      ],
    );

    blocTest<PostVoteBloc, PostVoteState>(
      'if vote state is downvoted, do nothing',
      setUp: () {
        when(() => postVoteRepo.downvote(any()))
            .thenAnswer((_) async => postVote(1));
      },
      tearDown: () => reset(postVoteRepo),
      seed: () => const PostVoteState(
        status: LoadStatus.initial,
        score: 0,
        upScore: 2,
        downScore: -2,
        state: VoteState.downvoted,
      ),
      build: () => PostVoteBloc(postVoteRepository: postVoteRepo),
      act: (bloc) => bloc.add(const PostVoteDownvoted(postId: 1)),
      expect: () => [],
    );

    blocTest<PostVoteBloc, PostVoteState>(
      'if vote state is upvoted, decrease score by 2, increase down score by 1, decrease up score by 1, change vote state to downvoted',
      setUp: () {
        when(() => postVoteRepo.downvote(any()))
            .thenAnswer((_) async => postVote(1));
      },
      tearDown: () => reset(postVoteRepo),
      seed: () => const PostVoteState(
        status: LoadStatus.success,
        score: 2,
        upScore: 3,
        downScore: -1,
        state: VoteState.upvoted,
      ),
      build: () => PostVoteBloc(postVoteRepository: postVoteRepo),
      act: (bloc) => bloc.add(const PostVoteDownvoted(postId: 1)),
      expect: () => [
        const PostVoteState(
          status: LoadStatus.loading,
          score: 2,
          upScore: 3,
          downScore: -1,
          state: VoteState.upvoted,
        ),
        const PostVoteState(
          status: LoadStatus.success,
          score: 0,
          upScore: 2,
          downScore: -2,
          state: VoteState.downvoted,
        ),
      ],
    );
  });
}
