// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/comments/comment.dart';
import '../../../../core/configs/config.dart';
import '../../../../core/riverpod/riverpod.dart';
import '../../moebooru.dart';
import 'moebooru_comment.dart';
import 'moebooru_comment_parser.dart';

final moebooruCommentRepoProvider =
    Provider.family<CommentRepository<MoebooruComment>, BooruConfigAuth>(
        (ref, config) {
  final client = ref.watch(moebooruClientProvider(config));

  return CommentRepositoryBuilder(
    fetch: (postId, {page}) => client
        .getComments(postId: postId)
        .then(
          (value) => value.map(moebooruCommentDtoToMoebooruComment).toList(),
        )
        .catchError((e) => <MoebooruComment>[]),
    create: (postId, body) async => false,
    update: (commentId, body) async => false,
    delete: (commentId) async => false,
  );
});

final moebooruCommentsProvider = FutureProvider.autoDispose
    .family<List<MoebooruComment>, (BooruConfigAuth, int)>((ref, params) {
  ref.cacheFor(const Duration(seconds: 60));

  final (config, postId) = params;
  return ref.watch(moebooruCommentRepoProvider(config)).getComments(postId);
});
