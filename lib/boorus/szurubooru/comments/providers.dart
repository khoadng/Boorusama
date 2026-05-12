// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/comments/types.dart';
import '../../../core/configs/config/types.dart';
import '../client_provider.dart';
import 'parser.dart';
import 'types.dart';

final szurubooruCommentRepoProvider =
    Provider.family<CommentRepository<SzurubooruComment>, BooruConfigAuth>((
      ref,
      config,
    ) {
      final client = ref.watch(szurubooruClientProvider(config));

      return CommentRepositoryBuilder(
        fetch: (postId, {page}) => client
            .getComments(postId: postId)
            .then(
              (value) => value.map(parseSzurubooruComment).toList(),
            ),
        create: (postId, body) => client
            .createComment(
              postId: postId,
              text: body,
            )
            .then((_) => true),
        update: (commentId, body) => client
            .updateComment(
              commentId: commentId,
              text: body,
            )
            .then((_) => true),
        delete: (commentId) => client.deleteComment(commentId: commentId),
      );
    });

final szurubooruCommentsProvider =
    NotifierProvider.family<
      SzurubooruCommentsNotifier,
      Map<int, AsyncValue<List<SzurubooruComment>>>,
      BooruConfigAuth
    >(
      SzurubooruCommentsNotifier.new,
    );

class SzurubooruCommentsNotifier
    extends
        FamilyNotifier<
          Map<int, AsyncValue<List<SzurubooruComment>>>,
          BooruConfigAuth
        > {
  @override
  Map<int, AsyncValue<List<SzurubooruComment>>> build(BooruConfigAuth arg) {
    return {};
  }

  CommentRepository<SzurubooruComment> get repo =>
      ref.read(szurubooruCommentRepoProvider(arg));

  Future<void> load(int postId, {bool force = false}) async {
    final current = state[postId];
    if (!force && (current?.hasValue ?? false)) return;

    state = {
      ...state,
      postId: const AsyncValue.loading(),
    };

    final result = await AsyncValue.guard(
      () => repo.getComments(postId).then(_sortDescById),
    );

    state = {
      ...state,
      postId: result,
    };
  }

  Future<void> send({
    required int postId,
    required String content,
  }) async {
    await repo.createComment(postId, content);
    await load(postId, force: true);
  }

  Future<void> update({
    required SzurubooruComment comment,
    required String content,
  }) async {
    final updated = await ref
        .read(szurubooruClientProvider(arg))
        .updateComment(
          commentId: comment.id,
          text: content,
          version: comment.version,
        )
        .then(parseSzurubooruComment);

    _replaceComment(updated);
  }

  Future<void> updateById({
    required int postId,
    required int commentId,
    required String content,
  }) async {
    await repo.updateComment(commentId, content);
    await load(postId, force: true);
  }

  Future<void> delete(SzurubooruComment comment) async {
    await ref
        .read(szurubooruClientProvider(arg))
        .deleteComment(
          commentId: comment.id,
          version: comment.version,
        );
    await load(comment.postId, force: true);
  }

  Future<void> upvote(SzurubooruComment comment) async {
    final updated = await ref
        .read(szurubooruClientProvider(arg))
        .upvoteComment(commentId: comment.id)
        .then(parseSzurubooruComment);

    _replaceComment(updated);
  }

  Future<void> downvote(SzurubooruComment comment) async {
    final updated = await ref
        .read(szurubooruClientProvider(arg))
        .downvoteComment(commentId: comment.id)
        .then(parseSzurubooruComment);

    _replaceComment(updated);
  }

  Future<void> unvote(SzurubooruComment comment) async {
    final updated = await ref
        .read(szurubooruClientProvider(arg))
        .unvoteComment(commentId: comment.id)
        .then(parseSzurubooruComment);

    _replaceComment(updated);
  }

  void _replaceComment(SzurubooruComment comment) {
    final current = state[comment.postId]?.valueOrNull;
    if (current == null) return;

    state = {
      ...state,
      comment.postId: AsyncValue.data(
        _sortDescById(
          current.map((e) => e.id == comment.id ? comment : e).toList(),
        ),
      ),
    };
  }
}

List<SzurubooruComment> _sortDescById(List<SzurubooruComment> comments) =>
    comments..sort((b, a) => b.id.compareTo(a.id));
