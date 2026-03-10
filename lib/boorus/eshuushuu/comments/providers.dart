// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/comments/types.dart';
import '../../../core/configs/config/types.dart';
import '../client_provider.dart';
import 'types.dart';

final eshuushuuCommentRepoProvider =
    Provider.family<CommentRepository<EshuushuuComment>, BooruConfigAuth>(
      (ref, config) {
        final client = ref.watch(eshuushuuClientProvider(config));

        return CommentRepositoryBuilder(
          fetch: (postId, {page}) => client
              .getComments(imageId: postId, page: page)
              .then(
                (dtos) => dtos
                    .map(EshuushuuComment.fromDto)
                    .where((c) => !c.isDeleted)
                    .toList(),
              )
              .catchError((Object _) => <EshuushuuComment>[]),
          create: (postId, body) async => false,
          update: (commentId, body) async => false,
          delete: (commentId) async {},
        );
      },
    );
