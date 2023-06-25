// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/gelbooru/feats/comments/comments.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_provider.dart';

final gelbooruCommentRepoProvider = Provider<GelbooruCommentRepository>(
  (ref) => GelbooruCommentRepositoryApi(
    api: ref.read(gelbooruApiProvider),
    booruConfig: ref.read(currentBooruConfigProvider),
  ),
);

final gelbooruCommentsProvider =
    FutureProvider.family<List<GelbooruComment>, int>((ref, postId) =>
        ref.read(gelbooruCommentRepoProvider).getComments(postId));
