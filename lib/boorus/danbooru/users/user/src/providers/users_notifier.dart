// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/posts/post/post.dart';
import '../../../../posts/favorites/favorite.dart';
import '../../../../posts/post/post.dart';
import '../../../../posts/post/providers.dart';
import '../types/user.dart';
import 'providers.dart';

final danbooruUserProvider =
    AsyncNotifierProvider.autoDispose.family<UserNotifier, DanbooruUser, int>(
  UserNotifier.new,
);

final danbooruUserFavoritesProvider = FutureProvider.autoDispose
    .family<List<DanbooruPost>, int>((ref, uid) async {
  final config = ref.watchConfigSearch;
  final user = await ref.watch(danbooruUserProvider(uid).future);
  final repo = ref.watch(danbooruPostRepoProvider(config));
  final favs = await repo.getPostsFromTagsOrEmpty(
    buildFavoriteQuery(user.name),
    limit: 50,
  );

  return favs.posts;
});

class UserNotifier extends AutoDisposeFamilyAsyncNotifier<DanbooruUser, int> {
  @override
  Future<DanbooruUser> build(int arg) async {
    final config = ref.watchConfigAuth;
    final user =
        await ref.watch(danbooruUserRepoProvider(config)).getUserById(arg);
    return user;
  }
}
