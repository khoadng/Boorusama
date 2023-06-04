// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/features/users/users.dart';

class CommentData extends Equatable {
  const CommentData({
    required this.id,
    required this.score,
    required this.authorName,
    required this.authorLevel,
    required this.authorId,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    required this.isSelf,
    required this.isEdited,
    required this.uris,
  });

  final int id;
  final int score;
  final String authorName;
  final UserLevel authorLevel;
  final UserId authorId;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSelf;
  final bool isEdited;
  final List<Uri> uris;

  @override
  List<Object?> get props => [
        id,
        score,
        authorName,
        authorLevel,
        authorId,
        body,
        createdAt,
        updatedAt,
        isSelf,
        isEdited,
        uris,
      ];
}
