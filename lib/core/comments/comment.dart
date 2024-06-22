// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/foundation/caching/caching.dart';

abstract class Comment {
  int get id;
  String get body;
  DateTime get createdAt;
  DateTime get updatedAt;
  String? get creatorName;
  int? get creatorId;
}

abstract class CommentRepository<T extends Comment> {
  Future<List<T>> getComments(int postId);
  Future<bool> createComment(int postId, String body);
  Future<bool> updateComment(int commentId, String body);
  Future<void> deleteComment(int commentId);
}

class CommentRepositoryBuilder<T extends Comment>
    with CacheMixin<T>
    implements CommentRepository<T> {
  CommentRepositoryBuilder({
    required this.fetch,
    required this.create,
    required this.update,
    required this.delete,
  });

  final Future<List<T>> Function(int postId) fetch;
  final Future<bool> Function(int postId, String body) create;
  final Future<bool> Function(int commentId, String body) update;
  final Future<void> Function(int commentId) delete;

  @override
  Future<List<T>> getComments(int postId) => fetch(postId);

  @override
  Future<bool> createComment(int postId, String body) => create(postId, body);

  @override
  Future<bool> updateComment(int commentId, String body) =>
      update(commentId, body);

  @override
  Future<void> deleteComment(int commentId) => delete(commentId);

  @override
  int get maxCapacity => 1000;

  @override
  Duration get staleDuration => const Duration(minutes: 5);
}

class SimpleComment extends Equatable implements Comment {
  const SimpleComment({
    required this.id,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    this.creatorName,
    this.creatorId,
  });

  @override
  final int id;
  @override
  final String body;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String? creatorName;
  @override
  final int? creatorId;

  @override
  List<Object?> get props => [id, body, createdAt, creatorName, creatorId];
}
