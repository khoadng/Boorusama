// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/comments/comment.dart';
import '../../../../../core/configs/config/types.dart';
import '../../../moebooru_provider.dart';
import '../types/moebooru_comment.dart';
import 'comment_parser.dart';

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
