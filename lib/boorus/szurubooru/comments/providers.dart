// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/comments/types.dart';
import '../../../core/configs/config/types.dart';
import '../client_provider.dart';
import 'parser.dart';

final szurubooruCommentRepoProvider =
    Provider.family<CommentRepository, BooruConfigAuth>((ref, config) {
      final client = ref.watch(szurubooruClientProvider(config));

      return CommentRepositoryBuilder(
        fetch: (postId, {page}) => client
            .getComments(postId: postId)
            .then(
              (value) => value.map(parseSzurubooruComment).toList(),
            ),
        create: (postId, body) async => false,
        update: (commentId, body) async => false,
        delete: (commentId) async => false,
      );
    });
