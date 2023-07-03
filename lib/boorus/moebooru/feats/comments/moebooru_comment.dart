// Package imports:
import 'package:equatable/equatable.dart';

class MoebooruComment extends Equatable {
  const MoebooruComment({
    required this.id,
    required this.createdAt,
    required this.postId,
    required this.creator,
    required this.creatorId,
    required this.body,
  });

  final int id;
  final DateTime createdAt;
  final int postId;
  final String creator;
  final int creatorId;
  final String body;

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
