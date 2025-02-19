// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/ref.dart';
import '../../../../danbooru_provider.dart';

final danbooruCommentCountProvider =
    FutureProvider.autoDispose.family<int, int>((ref, postId) {
  final client = ref.watch(danbooruClientProvider(ref.watchConfigAuth));

  return client.getCommentCount(postId: postId);
});
