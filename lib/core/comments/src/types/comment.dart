// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../../foundation/caching.dart';

abstract class Comment {
  int get id;
  String get body;
  DateTime? get createdAt;
  DateTime? get updatedAt;
  String? get creatorName;
  int? get creatorId;
}

abstract class CommentRepository<T extends Comment> {
  Future<List<T>> getComments(
    int postId, {
    int? page,
  });
  Future<bool> createComment(int postId, String body);
  Future<bool> updateComment(int commentId, String body);
  Future<void> deleteComment(int commentId);

  Future<CommentPage<T>> getCommentPage(
    int postId, {
    required CommentPageKey pageKey,
    CommentSortOrder? sortOrder,
  });
}

enum CommentSortOrder {
  newest,
  oldest,
}

sealed class CommentPageKey {
  const CommentPageKey();
}

final class InitialCommentPageKey extends CommentPageKey {
  const InitialCommentPageKey();
}

final class NumberedCommentPageKey extends CommentPageKey {
  const NumberedCommentPageKey(this.page);

  final int page;
}

final class CursorCommentPageKey extends CommentPageKey {
  const CursorCommentPageKey(this.cursor);

  final String cursor;
}

class CommentPage<T extends Comment> {
  const CommentPage({
    required this.items,
    this.nextPageKey,
  });

  final List<T> items;
  final CommentPageKey? nextPageKey;
}

class CommentRepositoryBuilder<T extends Comment>
    with CacheMixin<T>
    implements CommentRepository<T> {
  CommentRepositoryBuilder({
    required this.fetch,
    required this.create,
    required this.update,
    required this.delete,
    this.fetchPage,
  });

  final Future<List<T>> Function(int postId, {int? page}) fetch;
  final Future<bool> Function(int postId, String body) create;
  final Future<bool> Function(int commentId, String body) update;
  final Future<void> Function(int commentId) delete;
  final Future<CommentPage<T>> Function(
    int postId, {
    required CommentPageKey pageKey,
    CommentSortOrder? sortOrder,
  })?
  fetchPage;

  @override
  Future<List<T>> getComments(
    int postId, {
    int? page,
  }) => fetch(postId, page: page);

  @override
  Future<bool> createComment(int postId, String body) => create(postId, body);

  @override
  Future<bool> updateComment(int commentId, String body) =>
      update(commentId, body);

  @override
  Future<void> deleteComment(int commentId) => delete(commentId);

  @override
  Future<CommentPage<T>> getCommentPage(
    int postId, {
    required CommentPageKey pageKey,
    CommentSortOrder? sortOrder,
  }) async {
    if (fetchPage case final fetchPage?) {
      return fetchPage(
        postId,
        pageKey: pageKey,
        sortOrder: sortOrder,
      );
    }

    final page = switch (pageKey) {
      NumberedCommentPageKey(:final page) => page,
      _ => 1,
    };
    final items = await getComments(postId, page: page);
    return CommentPage(
      items: items,
      nextPageKey: items.isEmpty ? null : NumberedCommentPageKey(page + 1),
    );
  }

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
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final String? creatorName;
  @override
  final int? creatorId;

  @override
  List<Object?> get props => [id, body, createdAt, creatorName, creatorId];
}

class EmptyCommentRepository<T extends Comment>
    implements CommentRepository<T> {
  const EmptyCommentRepository();

  @override
  Future<List<T>> getComments(int postId, {int? page}) async => [];

  @override
  Future<bool> createComment(int postId, String body) async => false;

  @override
  Future<bool> updateComment(int commentId, String body) async => false;

  @override
  Future<void> deleteComment(int commentId) async {}

  @override
  Future<CommentPage<T>> getCommentPage(
    int postId, {
    required CommentPageKey pageKey,
    CommentSortOrder? sortOrder,
  }) async => const CommentPage(items: []);
}
