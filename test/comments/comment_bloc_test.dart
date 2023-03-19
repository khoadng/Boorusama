// Package imports:
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/comment/comment.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/comments.dart';
import 'package:boorusama/core/application/common.dart';

class MockCommentRepository extends Mock implements CommentRepository {}

class MockCommentVoteRepository extends Mock implements CommentVoteRepository {}

class MockAccountRepository extends Mock implements AccountRepository {}

void main() {
  final accountRepo = MockAccountRepository();
  final commentRepo = MockCommentRepository();
  final commentVoteRepo = MockCommentVoteRepository();

  group('[comment test]', () {
    blocTest<CommentBloc, CommentState>(
      'fetchet 2 comments',
      setUp: () {
        when(() => accountRepo.get())
            .thenAnswer((invocation) async => Account.empty);
        when(() => commentRepo.getCommentsFromPostId(any()))
            .thenAnswer((invocation) async => [
                  Comment.emty(),
                  Comment.emty(),
                ]);
        when(() => commentVoteRepo.getCommentVotes(any()))
            .thenAnswer((invocation) async => []);
      },
      tearDown: () {
        reset(accountRepo);
        reset(commentRepo);
        reset(commentVoteRepo);
      },
      build: () => CommentBloc(
        accountRepository: accountRepo,
        commentRepository: commentRepo,
        commentVoteRepository: commentVoteRepo,
      ),
      act: (bloc) => bloc.add(const CommentFetched(postId: 1)),
      expect: () => [
        CommentState.initial(),
        CommentState.initial().copyWith(
          status: LoadStatus.success,
          comments: [
            commentDataFrom(Comment.emty(), null, Account.empty, []),
            commentDataFrom(Comment.emty(), null, Account.empty, []),
          ],
        ),
      ],
    );

    blocTest<CommentBloc, CommentState>(
      'send comment',
      setUp: () {
        when(() => commentRepo.postComment(any(), any()))
            .thenAnswer((invocation) async => true);
        when(() => commentRepo.getCommentsFromPostId(any()))
            .thenAnswer((invocation) async => [
                  Comment.emty().copyWith(id: 1, body: 'a'),
                ]);
        when(() => accountRepo.get())
            .thenAnswer((invocation) async => Account.empty);
        when(() => commentVoteRepo.getCommentVotes(any()))
            .thenAnswer((invocation) async => []);
      },
      tearDown: () {
        reset(accountRepo);
        reset(commentRepo);
        reset(commentVoteRepo);
      },
      build: () => CommentBloc(
        accountRepository: accountRepo,
        commentRepository: commentRepo,
        commentVoteRepository: commentVoteRepo,
      ),
      act: (bloc) => bloc.add(const CommentSent(postId: 1, content: 'a')),
      expect: () => [
        CommentState.initial(),
        CommentState.initial().copyWith(
          status: LoadStatus.success,
          comments: [
            commentDataFrom(
              Comment.emty().copyWith(id: 1, body: 'a'),
              null,
              Account.empty,
              [],
            ),
          ],
        ),
      ],
    );

    test('comment content when send as a reply', () {
      const content = 'foo';
      final event = CommentSent(
        postId: 1,
        content: content,
        replyTo: commentDataFrom(Comment.emty(), null, Account.empty, []),
      );

      expect(
        buildCommentContent(event),
        '[quote]\n${event.replyTo!.authorName} said:\n\n${event.replyTo!.body}\n[/quote]\n\n$content',
      );
    });

    blocTest<CommentBloc, CommentState>(
      'update comment',
      setUp: () {
        when(() => commentRepo.updateComment(any(), any()))
            .thenAnswer((invocation) async => true);
        when(() => commentRepo.getCommentsFromPostId(any()))
            .thenAnswer((invocation) async => [
                  Comment.emty().copyWith(id: 1, body: 'bar'),
                ]);
        when(() => accountRepo.get())
            .thenAnswer((invocation) async => Account.empty);
        when(() => commentVoteRepo.getCommentVotes(any()))
            .thenAnswer((invocation) async => []);
      },
      tearDown: () {
        reset(accountRepo);
        reset(commentRepo);
        reset(commentVoteRepo);
      },
      seed: () => CommentState.initial().copyWith(comments: [
        commentDataFrom(
          Comment.emty().copyWith(id: 1, body: 'foo'),
          null,
          Account.empty,
          [],
        ),
      ]),
      build: () => CommentBloc(
        accountRepository: accountRepo,
        commentRepository: commentRepo,
        commentVoteRepository: commentVoteRepo,
      ),
      act: (bloc) => bloc
          .add(const CommentUpdated(commentId: 1, postId: 1, content: 'bar')),
      expect: () => [
        CommentState.initial().copyWith(
          status: LoadStatus.success,
          comments: [
            commentDataFrom(
              Comment.emty().copyWith(id: 1, body: 'bar'),
              null,
              Account.empty,
              [],
            ),
          ],
        ),
      ],
    );

    blocTest<CommentBloc, CommentState>(
      'delete first comment of the two',
      setUp: () {
        when(() => commentRepo.deleteComment(any()))
            .thenAnswer((invocation) async => true);
        when(() => commentRepo.getCommentsFromPostId(any()))
            .thenAnswer((invocation) async => [
                  Comment.emty().copyWith(id: 1, body: 'foo2'),
                ]);
        when(() => accountRepo.get())
            .thenAnswer((invocation) async => Account.empty);
        when(() => commentVoteRepo.getCommentVotes(any()))
            .thenAnswer((invocation) async => []);
      },
      tearDown: () {
        reset(accountRepo);
        reset(commentRepo);
        reset(commentVoteRepo);
      },
      seed: () => CommentState.initial().copyWith(comments: [
        commentDataFrom(
          Comment.emty().copyWith(id: 1, body: 'foo1'),
          null,
          Account.empty,
          [],
        ),
        commentDataFrom(
          Comment.emty().copyWith(id: 2, body: 'foo2'),
          null,
          Account.empty,
          [],
        ),
      ]),
      build: () => CommentBloc(
        accountRepository: accountRepo,
        commentRepository: commentRepo,
        commentVoteRepository: commentVoteRepo,
      ),
      act: (bloc) => bloc.add(const CommentDeleted(commentId: 1, postId: 1)),
      expect: () => [
        CommentState.initial().copyWith(
          status: LoadStatus.success,
          comments: [
            commentDataFrom(
              Comment.emty().copyWith(id: 1, body: 'foo2'),
              null,
              Account.empty,
              [],
            ),
          ],
        ),
      ],
    );

    blocTest<CommentBloc, CommentState>(
      'upvote comment',
      setUp: () {
        when(() => commentVoteRepo.upvote(any())).thenAnswer(
          (invocation) async =>
              CommentVote.empty().copyWith(id: 2, commentId: 1, score: 1),
        );
      },
      tearDown: () {
        reset(commentVoteRepo);
      },
      seed: () => CommentState.initial().copyWith(
        status: LoadStatus.success,
        comments: [
          commentDataFrom(
            Comment.emty().copyWith(id: 1, score: 1, body: 'foo1'),
            null,
            Account.empty,
            [
              CommentVote.empty().copyWith(id: 1, score: 1),
            ],
          ),
        ],
      ),
      build: () => CommentBloc(
        accountRepository: accountRepo,
        commentRepository: commentRepo,
        commentVoteRepository: commentVoteRepo,
      ),
      act: (bloc) => bloc.add(const CommentUpvoted(commentId: 1)),
      expect: () => [
        CommentState.initial().copyWith(
          status: LoadStatus.success,
          comments: [
            commentDataFrom(
              Comment.emty().copyWith(id: 1, score: 2, body: 'foo1'),
              null,
              Account.empty,
              [
                CommentVote.empty().copyWith(id: 1, commentId: 1, score: 1),
                CommentVote.empty().copyWith(id: 2, commentId: 1, score: 1),
              ],
            ),
          ],
        ),
      ],
    );

    blocTest<CommentBloc, CommentState>(
      'downvote comment',
      setUp: () {
        when(() => commentVoteRepo.downvote(any())).thenAnswer(
          (invocation) async =>
              CommentVote.empty().copyWith(id: 2, commentId: 1, score: -1),
        );
      },
      tearDown: () {
        reset(commentVoteRepo);
      },
      seed: () => CommentState.initial().copyWith(
        status: LoadStatus.success,
        comments: [
          commentDataFrom(
            Comment.emty().copyWith(id: 1, score: 0, body: 'foo1'),
            null,
            Account.empty,
            [],
          ),
        ],
      ),
      build: () => CommentBloc(
        accountRepository: accountRepo,
        commentRepository: commentRepo,
        commentVoteRepository: commentVoteRepo,
      ),
      act: (bloc) => bloc.add(const CommentDownvoted(commentId: 1)),
      expect: () => [
        CommentState.initial().copyWith(
          status: LoadStatus.success,
          comments: [
            commentDataFrom(
              Comment.emty().copyWith(id: 1, score: -1, body: 'foo1'),
              null,
              Account.empty,
              [
                CommentVote.empty().copyWith(id: 2, commentId: 1, score: -1),
              ],
            ),
          ],
        ),
      ],
    );

    blocTest<CommentBloc, CommentState>(
      'remove upvote comment',
      setUp: () {
        when(() => commentVoteRepo.removeVote(any()))
            .thenAnswer((invocation) async => true);
      },
      tearDown: () {
        reset(commentVoteRepo);
      },
      seed: () => CommentState.initial().copyWith(
        status: LoadStatus.success,
        comments: [
          commentDataFrom(
            Comment.emty().copyWith(id: 1, score: 1, body: 'foo1'),
            null,
            Account.empty,
            [
              CommentVote.empty().copyWith(id: 2, commentId: 1, score: 1),
            ],
          ),
        ],
      ),
      build: () => CommentBloc(
        accountRepository: accountRepo,
        commentRepository: commentRepo,
        commentVoteRepository: commentVoteRepo,
      ),
      act: (bloc) => bloc.add(const CommentVoteRemoved(
        commentId: 1,
        commentVoteId: 2,
        voteState: CommentVoteState.upvoted,
      )),
      expect: () => [
        CommentState.initial().copyWith(
          status: LoadStatus.success,
          comments: [
            commentDataFrom(
              Comment.emty().copyWith(id: 1, score: 0, body: 'foo1'),
              null,
              Account.empty,
              [],
            ),
          ],
        ),
      ],
    );

    blocTest<CommentBloc, CommentState>(
      'remove downvote comment',
      setUp: () {
        when(() => commentVoteRepo.removeVote(any()))
            .thenAnswer((invocation) async => true);
      },
      tearDown: () {
        reset(commentVoteRepo);
      },
      seed: () => CommentState.initial().copyWith(
        status: LoadStatus.success,
        comments: [
          commentDataFrom(
            Comment.emty().copyWith(id: 1, score: -1, body: 'foo1'),
            null,
            Account.empty,
            [
              CommentVote.empty().copyWith(id: 2, commentId: 1, score: -1),
            ],
          ),
        ],
      ),
      build: () => CommentBloc(
        accountRepository: accountRepo,
        commentRepository: commentRepo,
        commentVoteRepository: commentVoteRepo,
      ),
      act: (bloc) => bloc.add(const CommentVoteRemoved(
        commentId: 1,
        commentVoteId: 2,
        voteState: CommentVoteState.downvoted,
      )),
      expect: () => [
        CommentState.initial().copyWith(
          status: LoadStatus.success,
          comments: [
            commentDataFrom(
              Comment.emty().copyWith(id: 1, score: 0, body: 'foo1'),
              null,
              Account.empty,
              [],
            ),
          ],
        ),
      ],
    );
  });
}
