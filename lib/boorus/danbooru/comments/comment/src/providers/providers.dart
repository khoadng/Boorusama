// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/configs/ref.dart';

final danbooruCommentCountProvider =
    FutureProvider.autoDispose.family<int, int>((ref, postId) {
  final client = ref.watch(danbooruClientProvider(ref.watchConfigAuth));

  return client.getCommentCount(postId: postId);
});
