import 'package:equatable/equatable.dart';

class PostVoteDto {
  PostVoteDto({
    required this.id,
    required this.postId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.score,
    required this.isDeleted,
  });

  factory PostVoteDto.fromJson(Map<String, dynamic> json) => PostVoteDto(
    id: PostVoteId.tryParse(json['id']),
    postId: switch (json['post_id']) {
      final int i => i,
      _ => null,
    },
    userId: switch (json['user_id']) {
      final int i => i,
      _ => null,
    },
    createdAt: switch (json['created_at']) {
      final String s => DateTime.tryParse(s),
      _ => null,
    },
    updatedAt: switch (json['updated_at']) {
      final String s => DateTime.tryParse(s),
      _ => null,
    },
    score: switch (json['score']) {
      final int i => i,
      _ => null,
    },
    isDeleted: switch (json['is_deleted']) {
      final bool b => b,
      _ => null,
    },
  );

  final PostVoteId? id;
  final int? postId;
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? score;
  final bool? isDeleted;
}

class PostVoteId extends Equatable {
  const PostVoteId._(this.value);

  const PostVoteId.fromInt(this.value);

  static PostVoteId? tryParse(dynamic id) => switch (id) {
    int i => PostVoteId._(i),
    _ => null,
  };

  final int value;

  @override
  String toString() => value.toString();

  @override
  List<Object?> get props => [value];
}
