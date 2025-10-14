// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/comments/types.dart';
import '../../../../../../core/configs/config/types.dart';
import '../../../../client_provider.dart';
import '../types/danbooru_comment.dart';
import 'converter.dart';

final danbooruCommentRepoProvider =
    Provider.family<CommentRepository<DanbooruComment>, BooruConfigAuth>((
      ref,
      config,
    ) {
      final client = ref.watch(danbooruClientProvider(config));

      return CommentRepositoryBuilder(
        fetch: (postId, {page}) => client
            .getComments(postId: postId, limit: 1000)
            .then((dtos) => dtos.map(commentDtoToComment).toList()),
        create: (postId, body) => client
            .postComment(postId: postId, content: body)
            .then((_) => true)
            .catchError((Object obj) => false),
        update: (commentId, body) => client
            .updateComment(commentId: commentId, content: body)
            .then((_) => true)
            .catchError((Object obj) => false),
        delete: (commentId) => client
            .deleteComment(commentId: commentId)
            .then((_) => true)
            .catchError((Object obj) => false),
      );
    });
