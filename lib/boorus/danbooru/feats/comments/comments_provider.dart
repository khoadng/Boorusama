// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/comments/comments.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';

final danbooruCommentRepoProvider =
    Provider.family<CommentRepository, BooruConfig>((ref, config) {
  return CommentRepositoryApi(
    ref.watch(danbooruClientProvider(config)),
  );
});

final danbooruCommentsProvider = NotifierProvider.family<CommentsNotifier,
    Map<int, List<CommentData>?>, BooruConfig>(
  CommentsNotifier.new,
  dependencies: [
    booruUserIdentityProviderProvider,
    currentBooruConfigProvider,
  ],
);

final danbooruCommentProvider =
    Provider.autoDispose.family<List<CommentData>?, int>((ref, postId) {
  final config = ref.watchConfig;
  return ref.watch(danbooruCommentsProvider(config))[postId];
});
