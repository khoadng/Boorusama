// Package imports:
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/users.dart';

class MockPostVoteRepository extends Mock implements PostVoteRepository {}

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  final postVoteRepo = MockPostVoteRepository();
  final userRepo = MockUserRepository();

  blocTest<PostVoteInfoBloc, PostVoteInfoState>(
    'refresh 2 votes',
    setUp: () {
      when(() => postVoteRepo.getAllVotes(any(), any()))
          .thenAnswer((invocation) async => [
                PostVote.empty().copyWith(id: 1, userId: 1),
                PostVote.empty().copyWith(id: 2, userId: 2),
              ]);

      when(() => userRepo.getUsersByIdStringComma(any()))
          .thenAnswer((invocation) async => [
                User.placeholder().copyWith(id: 1),
                User.placeholder().copyWith(id: 2),
              ]);
    },
    tearDown: () {
      reset(postVoteRepo);
      reset(userRepo);
    },
    build: () => PostVoteInfoBloc(
      postVoteRepository: postVoteRepo,
      userRepository: userRepo,
    ),
    act: (bloc) =>
        bloc.add(const PostVoteInfoFetched(postId: 1, refresh: true)),
    expect: () => [
      PostVoteInfoState.initial().copyWith(refreshing: true),
      PostVoteInfoState.initial().copyWith(
        refreshing: false,
        upvoters: [
          Voter.create(
            User.placeholder().copyWith(id: 1),
            PostVote.empty().copyWith(id: 1, userId: 1),
          ),
          Voter.create(
            User.placeholder().copyWith(id: 2),
            PostVote.empty().copyWith(id: 2, userId: 2),
          ),
        ],
      ),
    ],
  );

  blocTest<PostVoteInfoBloc, PostVoteInfoState>(
    'refresh a post with no votes',
    setUp: () {
      when(() => postVoteRepo.getAllVotes(any(), any()))
          .thenAnswer((invocation) async => []);

      when(() => userRepo.getUsersByIdStringComma(any()))
          .thenAnswer((invocation) async => []);
    },
    tearDown: () {
      reset(postVoteRepo);
      reset(userRepo);
    },
    build: () => PostVoteInfoBloc(
      postVoteRepository: postVoteRepo,
      userRepository: userRepo,
    ),
    act: (bloc) =>
        bloc.add(const PostVoteInfoFetched(postId: 1, refresh: true)),
    expect: () => [
      PostVoteInfoState.initial().copyWith(refreshing: true),
      PostVoteInfoState.initial().copyWith(
        refreshing: false,
        upvoters: [],
      ),
    ],
  );

  blocTest<PostVoteInfoBloc, PostVoteInfoState>(
    'have 2 votes then fetch 2 more votes',
    setUp: () {
      when(() => postVoteRepo.getAllVotes(any(), any()))
          .thenAnswer((invocation) async => [
                PostVote.empty().copyWith(id: 3, userId: 3),
                PostVote.empty().copyWith(id: 4, userId: 4),
              ]);

      when(() => userRepo.getUsersByIdStringComma(any()))
          .thenAnswer((invocation) async => [
                User.placeholder().copyWith(id: 3),
                User.placeholder().copyWith(id: 4),
              ]);
    },
    tearDown: () {
      reset(postVoteRepo);
      reset(userRepo);
    },
    build: () => PostVoteInfoBloc(
      postVoteRepository: postVoteRepo,
      userRepository: userRepo,
      initialVoters: [
        Voter.create(
          User.placeholder().copyWith(id: 1),
          PostVote.empty().copyWith(id: 1, userId: 1),
        ),
        Voter.create(
          User.placeholder().copyWith(id: 2),
          PostVote.empty().copyWith(id: 2, userId: 2),
        ),
      ],
    ),
    act: (bloc) => bloc.add(const PostVoteInfoFetched(postId: 1)),
    expect: () => [
      PostVoteInfoState.initial().copyWith(
        loading: true,
        upvoters: [
          Voter.create(
            User.placeholder().copyWith(id: 1),
            PostVote.empty().copyWith(id: 1, userId: 1),
          ),
          Voter.create(
            User.placeholder().copyWith(id: 2),
            PostVote.empty().copyWith(id: 2, userId: 2),
          ),
        ],
      ),
      PostVoteInfoState.initial().copyWith(
        loading: false,
        page: 2,
        upvoters: [
          Voter.create(
            User.placeholder().copyWith(id: 1),
            PostVote.empty().copyWith(id: 1, userId: 1),
          ),
          Voter.create(
            User.placeholder().copyWith(id: 2),
            PostVote.empty().copyWith(id: 2, userId: 2),
          ),
          Voter.create(
            User.placeholder().copyWith(id: 3),
            PostVote.empty().copyWith(id: 3, userId: 3),
          ),
          Voter.create(
            User.placeholder().copyWith(id: 4),
            PostVote.empty().copyWith(id: 4, userId: 24),
          ),
        ],
      ),
    ],
  );
}
