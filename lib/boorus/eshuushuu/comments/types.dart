// Package imports:
import 'package:booru_clients/eshuushuu.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../core/comments/types.dart';

class EshuushuuComment extends Equatable implements Comment {
  const EshuushuuComment({
    required this.id,
    required this.body,
    this.createdAt,
    this.updatedAt,
    this.creatorName,
    this.creatorId,
    this.creatorAvatarUrl,
    this.parentCommentId,
    this.imageId,
    this.isDeleted = false,
    this.updateCount = 0,
  });

  factory EshuushuuComment.fromDto(CommentDto dto) {
    return EshuushuuComment(
      id: dto.postId ?? 0,
      body: dto.postTextHtml ?? dto.postText ?? '',
      createdAt: dto.date,
      updatedAt: dto.lastUpdated,
      creatorName: dto.username,
      creatorId: dto.userId,
      creatorAvatarUrl: dto.userAvatarUrl,
      parentCommentId: dto.parentCommentId,
      imageId: dto.imageId,
      isDeleted: dto.deleted ?? false,
      updateCount: dto.updateCount ?? 0,
    );
  }

  @override
  final int id;
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
  final String? creatorAvatarUrl;
  final int? parentCommentId;
  final int? imageId;
  final bool isDeleted;
  final int updateCount;

  bool get isReply => parentCommentId != null;
  bool get isEdited => updateCount > 0;

  @override
  List<Object?> get props => [
    id,
    body,
    createdAt,
    updatedAt,
    creatorName,
    creatorId,
    parentCommentId,
    imageId,
    isDeleted,
    updateCount,
  ];
}
