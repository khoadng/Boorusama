// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/core/feats/comments/comments.dart';
import 'package:boorusama/boorus/gelbooru/feats/comments/comments.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru.dart';

final gelbooruCommentRepoProvider = Provider<GelbooruCommentRepository>(
  (ref) => GelbooruCommentRepositoryApi(
    client: ref.watch(gelbooruClientProvider),
    booruConfig: ref.watch(currentBooruConfigProvider),
  ),
);

final gelbooruCommentsProvider = FutureProvider.family<List<Comment>, int>(
    (ref, postId) =>
        ref.watch(gelbooruCommentRepoProvider).getComments(postId));
