// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/posts/post/post.dart';
import '../../favorites/favorite.dart';
import '../../posts/post/danbooru_post.dart';
import '../../posts/post/providers.dart';
import 'providers.dart';
import 'user.dart';

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
