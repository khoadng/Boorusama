// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'comments.dart';

final danbooruCommentVoteRepoProvider =
    Provider.family<CommentVoteApiRepository, BooruConfig>((ref, config) {
  return CommentVoteApiRepository(
    ref.watch(danbooruClientProvider(config)),
  );
});

final danbooruCommentVotesProvider = NotifierProvider.family<
    CommentVotesNotifier, Map<CommentId, CommentVote>, BooruConfig>(
  CommentVotesNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
  ],
);

// comment vote for a single comment
final danbooruCommentVoteProvider =
    Provider.autoDispose.family<CommentVote?, CommentId>((ref, commentId) {
  final config = ref.watchConfig;
  final votes = ref.watch(danbooruCommentVotesProvider(config));
  return votes[commentId];
});
