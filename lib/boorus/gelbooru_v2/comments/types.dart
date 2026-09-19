// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../core/comments/types.dart';

class GelbooruV2Comment extends Equatable implements Comment {
  const GelbooruV2Comment({
    required this.id,
    required this.postId,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    required this.creatorName,
    required this.creatorId,
    required this.score,
  });

  @override
  final int id;
  final int? postId;
  @override
  final String body;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final String? creatorName;
  @override
  final int? creatorId;
  final int? score;

  @override
  List<Object?> get props => [
    id,
    postId,
    body,
    createdAt,
    updatedAt,
    creatorName,
    creatorId,
    score,
  ];
}
