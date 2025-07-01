// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'comment.dart';

final emptyCommentRepoProvider = Provider<CommentRepository<Comment>>((ref) {
  return const EmptyCommentRepository();
});
