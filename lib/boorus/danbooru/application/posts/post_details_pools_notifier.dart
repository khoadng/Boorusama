// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';

final danbooruPostDetailsPoolsProvider = NotifierProvider.autoDispose
    .family<PostDetailsPoolsNotifier, List<Pool>, int>(
  PostDetailsPoolsNotifier.new,
  dependencies: [
    poolRepoProvider,
  ],
);

class PostDetailsPoolsNotifier
    extends AutoDisposeFamilyNotifier<List<Pool>, int> {
  @override
  List<Pool> build(int arg) {
    return [];
  }

  Future<void> load() async {
    state = await _loadPools(arg);
  }

  Future<List<Pool>> _loadPools(int postId) =>
      ref.read(poolRepoProvider).getPoolsByPostId(postId);
}
