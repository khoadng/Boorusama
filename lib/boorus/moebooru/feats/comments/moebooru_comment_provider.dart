// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/moebooru/moebooru.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'moebooru_comment.dart';
import 'moebooru_comment_repository.dart';

final moebooruCommentRepoProvider =
    Provider.family<MoebooruCommentRepository, BooruConfig>((ref, config) {
  return MoebooruCommentRepositoryApi(
    client: ref.watch(moebooruClientProvider(config)),
    booruConfig: ref.watchConfig,
  );
});

final moebooruCommentsProvider = FutureProvider.autoDispose
    .family<List<MoebooruComment>, int>((ref, postId) {
  final config = ref.watchConfig;
  return ref.watch(moebooruCommentRepoProvider(config)).getComments(postId);
});
