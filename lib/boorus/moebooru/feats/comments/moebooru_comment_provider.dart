// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/moebooru/moebooru.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'moebooru_comment.dart';
import 'moebooru_comment_repository.dart';

final moebooruCommentRepoProvider = Provider<MoebooruCommentRepository>((ref) {
  return MoebooruCommentRepositoryApi(
    client: ref.watch(moebooruClientProvider),
    booruConfig: ref.watch(currentBooruConfigProvider),
  );
});

final moebooruCommentsProvider =
    FutureProvider.family<List<MoebooruComment>, int>((ref, postId) =>
        ref.watch(moebooruCommentRepoProvider).getComments(postId));
