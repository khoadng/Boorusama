// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../configs/config.dart';
import '../../../post/post.dart';
import '../../../post/providers.dart';

final singlePostDetailsProvider = FutureProvider.autoDispose
    .family<Post?, (PostId, BooruConfigSearch)>((ref, params) async {
  final (id, config) = params;

  final postRepo = ref.watch(postRepoProvider(config));

  final result = await postRepo.getPost(id).run();

  return result.getOrElse((_) => null);
});
