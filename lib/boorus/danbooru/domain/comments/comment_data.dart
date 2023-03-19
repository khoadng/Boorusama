// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/comments.dart';
import 'package:boorusama/boorus/danbooru/domain/users.dart';
import 'package:boorusama/core/application/application.dart';

enum CommentVoteState {
  unvote,
  downvoted,
  upvoted,
}

const youtubeUrl = 'www.youtube.com';

class CommentData extends Equatable {
  const CommentData({
    required this.id,
    required this.authorName,
    required this.authorLevel,
    required this.authorId,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    required this.score,
    required this.isSelf,
    required this.recentlyUpdated,
    required this.voteState,
    this.voteId,
    required this.uris,
  });

  final int id;
  final String authorName;
  final UserLevel authorLevel;
  final UserId authorId;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int score;
  final bool isSelf;
  final bool recentlyUpdated;
  final int? voteId;
  final CommentVoteState voteState;
  final List<Uri> uris;

  bool get hasVote => voteState != CommentVoteState.unvote;

  CommentData copyWith({
    int? score,
    CommentVoteState? voteState,
    int? voteId,
  }) =>
      CommentData(
        id: id,
        authorName: authorName,
        authorLevel: authorLevel,
        authorId: authorId,
        body: body,
        createdAt: createdAt,
        updatedAt: updatedAt,
        score: score ?? this.score,
        isSelf: isSelf,
        recentlyUpdated: recentlyUpdated,
        voteState: voteState ?? this.voteState,
        voteId: voteId,
        uris: uris,
      );

  @override
  List<Object?> get props => [
        id,
        authorName,
        authorLevel,
        authorId,
        body,
        createdAt,
        updatedAt,
        score,
        isSelf,
        recentlyUpdated,
        voteState,
        voteId,
        uris,
      ];
}

List<CommentData> Function(List<CommentData> comments) sortDescendedById() =>
    (comments) => comments..sort((a, b) => a.id.compareTo(b.id));

CommentData Function(Comment comment) createCommentData({
  required Account account,
  required List<CommentVote> votes,
}) =>
    (comment) => commentDataFrom(comment, comment.creator, account, votes);

Future<List<CommentData>> Function(List<Comment> comments)
    createCommentDataWith(
  AccountRepository accountRepository,
  CommentVoteRepository commentVoteRepository,
) =>
        (comments) async {
          final votes = await commentVoteRepository
              .getCommentVotes(comments.map((e) => e.id).toList());
          final account = await accountRepository.get();

          return comments
              .map(createCommentData(
                account: account,
                votes: votes,
              ))
              .toList();
        };

CommentData commentDataFrom(
  Comment comment,
  User? user,
  Account account,
  List<CommentVote> votes,
) =>
    CommentData(
      id: comment.id,
      authorName: user?.name ?? 'User',
      authorLevel: user?.level ?? UserLevel.member,
      authorId: user?.id ?? 0,
      body: comment.body,
      createdAt: comment.createdAt,
      updatedAt: comment.updatedAt,
      score: comment.score,
      isSelf: comment.creator?.id == account.id,
      recentlyUpdated: comment.createdAt != comment.updatedAt,
      voteState: _getVoteState(comment, votes),
      voteId: {for (final v in votes) v.commentId: v}[comment.id]?.id,
      uris: RegExp(urlPattern)
          .allMatches(comment.body)
          .map((match) {
            try {
              final url = comment.body.substring(match.start, match.end);

              return Uri.parse(url);
            } catch (e) {
              return null;
            }
          })
          .whereNotNull()
          .where((e) => e.host.contains(youtubeUrl))
          .toList(),
    );

CommentVoteState _getVoteState(Comment comment, List<CommentVote> votes) {
  final voteMap = {
    for (var i = 0; i < votes.length; i += 1) votes[i].commentId: votes[i],
  };
  final hasVote = voteMap.containsKey(comment.id);

  if (!hasVote) return CommentVoteState.unvote;

  final score = voteMap[comment.id]!.score;

  if (score == 1) {
    return CommentVoteState.upvoted;
  } else if (score == -1) {
    return CommentVoteState.downvoted;
  } else {
    return CommentVoteState.unvote;
  }
}
