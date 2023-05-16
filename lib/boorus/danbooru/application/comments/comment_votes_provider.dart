// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/comments.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/comments/comments.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/provider.dart';
import 'comment_votes_notifier.dart';

final danbooruCommentVoteRepoProvider =
    Provider<CommentVoteApiRepository>((ref) {
  final api = ref.watch(danbooruApiProvider);
  final currentBooruConfigRepository =
      ref.watch(currentBooruConfigRepoProvider);

  return CommentVoteApiRepository(api, currentBooruConfigRepository);
});

final danbooruCommentVotesProvider =
    NotifierProvider<CommentVotesNotifier, Map<CommentId, CommentVote>>(
  CommentVotesNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
  ],
);

// comment vote for a single comment
final danbooruCommentVoteProvider =
    Provider.autoDispose.family<CommentVote?, CommentId>((ref, commentId) {
  final votes = ref.watch(danbooruCommentVotesProvider);
  return votes[commentId];
});
