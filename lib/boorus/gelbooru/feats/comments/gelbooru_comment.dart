// Package imports:
import 'package:equatable/equatable.dart';

class GelbooruComment extends Equatable {
  const GelbooruComment({
    required this.id,
    required this.postId,
    required this.body,
    required this.creatorId,
    required this.creator,
    required this.createdAt,
  });

  final int id;
  final int postId;
  final String body;
  final int creatorId;
  final String creator;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        postId,
        body,
        creatorId,
        createdAt,
        creator,
      ];
}
