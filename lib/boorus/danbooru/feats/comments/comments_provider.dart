// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/comments/comments.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/providers.dart';

final danbooruCommentRepoProvider = Provider<CommentRepository>((ref) {
  return CommentRepositoryApi(
    ref.watch(danbooruClientProvider),
  );
});

final danbooruCommentsProvider =
    NotifierProvider<CommentsNotifier, Map<int, List<CommentData>?>>(
  CommentsNotifier.new,
  dependencies: [
    booruUserIdentityProviderProvider,
    currentBooruConfigProvider,
  ],
);

final danbooruCommentProvider = Provider.family<List<CommentData>?, int>(
    (ref, postId) => ref.watch(danbooruCommentsProvider)[postId]);
