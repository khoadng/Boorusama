// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../../core/comments/comment.dart';

class MoebooruComment extends Equatable implements Comment {
  const MoebooruComment({
    required this.id,
    required this.createdAt,
    required this.postId,
    required this.creator,
    required this.creatorId,
    required this.body,
    this.creatorName,
  });

  @override
  final int id;
  @override
  final DateTime createdAt;
  final int postId;
  final String creator;
  @override
  final int creatorId;
  @override
  final String body;
  @override
  final String? creatorName;
  @override
  DateTime get updatedAt => createdAt;

  @override
  List<Object> get props => [
        id,
        createdAt,
        postId,
        creator,
        creatorId,
        body,
      ];
}
