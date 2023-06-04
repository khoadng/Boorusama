// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feat/pools/pools.dart';

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
      ref.read(danbooruPoolRepoProvider).getPoolsByPostId(postId);
}
