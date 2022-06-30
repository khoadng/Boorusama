// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/account.dart';
import 'package:boorusama/boorus/danbooru/domain/comments/comment.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';

class CommentData extends Equatable {
  const CommentData({
    required this.id,
    required this.authorName,
    required this.authorLevel,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    required this.score,
    required this.isSelf,
    required this.recentlyUpdated,
  });

  final int id;
  final String authorName;
  final UserLevel authorLevel;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int score;
  final bool isSelf;
  final bool recentlyUpdated;

  @override
  List<Object?> get props => [
        id,
        authorName,
        authorLevel,
        body,
        createdAt,
        updatedAt,
        score,
        isSelf,
        recentlyUpdated,
      ];
}

CommentData commentDataFrom(
  Comment comment,
  User? user,
  Account account,
) =>
    CommentData(
      id: comment.id,
      authorName: user?.name.value ?? 'User',
      authorLevel: user?.level ?? UserLevel.member,
      body: comment.body,
      createdAt: comment.createdAt,
      updatedAt: comment.updatedAt,
      score: comment.score,
      isSelf: comment.creatorId == account.id,
      recentlyUpdated: comment.createdAt != comment.updatedAt,
    );
