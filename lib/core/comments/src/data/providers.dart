// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../boorus/engine/providers.dart';
import '../../../configs/config/types.dart';
import '../types/comment.dart';
import '../types/comment_extractor.dart';

final emptyCommentRepoProvider = Provider<CommentRepository<Comment>>((ref) {
  return const EmptyCommentRepository();
});

final commentRepoProvider =
    Provider.family<CommentRepository?, BooruConfigAuth>(
      (ref, config) {
        final repository = ref
            .watch(booruEngineRegistryProvider)
            .getRepository(config.booruType);

        if (repository == null) return null;

        return repository.comment(config);
      },
      name: 'commentRepoProvider',
    );

final unsupportedCommentExtractor = Provider<CommentExtractor>(
  (ref) => const UnsupportedCommentExtractor(),
);
