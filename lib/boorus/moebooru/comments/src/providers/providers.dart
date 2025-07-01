// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config/types.dart';
import '../../../../../core/riverpod/riverpod.dart';
import '../data/providers.dart';
import '../types/moebooru_comment.dart';

final moebooruCommentsProvider = FutureProvider.autoDispose
    .family<List<MoebooruComment>, (BooruConfigAuth, int)>((ref, params) {
  ref.cacheFor(const Duration(seconds: 60));

  final (config, postId) = params;
  return ref.watch(moebooruCommentRepoProvider(config)).getComments(postId);
});
