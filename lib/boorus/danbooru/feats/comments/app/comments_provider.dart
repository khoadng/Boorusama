// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/comments/comments.dart';

final danbooruCommentRepoProvider = Provider<CommentRepository>((ref) {
  final api = ref.watch(danbooruApiProvider);
  final booruConfig = ref.watch(currentBooruConfigProvider);

  return CommentRepositoryApi(api, booruConfig);
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
