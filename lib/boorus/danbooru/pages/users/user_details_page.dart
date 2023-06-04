// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'user_info_box.dart';
import 'user_stats_group.dart';

class UserDetailsPage extends ConsumerWidget {
  const UserDetailsPage({
    super.key,
    required this.uid,
  });

  final int uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(danbooruUserProvider(uid));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: state.when(
          data: (user) => Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: UserInfoBox(user: user),
                      ),
                      const SizedBox(height: 12),
                      UserStatsGroup(user: user),
                      _UserUploads(uid: uid, user: user),
                      _UserFavorites(uid: uid, user: user),
                    ],
                  ),
                ),
              ],
            ),
          ),
          error: (error, stackTrace) => const Center(
            child: Text('Fail to load profile'),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

class _UserFavorites extends ConsumerWidget {
  const _UserFavorites({
    required this.uid,
    required this.user,
  });

  final int uid;
  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(danbooruUserFavoritesProvider(uid));

    return state.when(
      data: (favorites) => favorites.isNotEmpty
          ? Column(
              children: [
                const Divider(
                  thickness: 2,
                  height: 36,
                ),
                _PreviewList(
                  posts: favorites,
                  onViewMore: () =>
                      goToSearchPage(context, tag: 'ordfav:${user.name}'),
                  title: 'Favorites',
                ),
              ],
            )
          : const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }
}

class _UserUploads extends ConsumerWidget {
  const _UserUploads({
    required this.uid,
    required this.user,
  });

  final int uid;
  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(danbooruUserUploadsProvider(uid));

    return state.when(
      data: (uploads) => uploads.isNotEmpty
          ? Column(
              children: [
                const Divider(
                  thickness: 2,
                  height: 26,
                ),
                _PreviewList(
                  posts: uploads,
                  onViewMore: () =>
                      goToSearchPage(context, tag: 'user:${user.name}'),
                  title: 'Uploads',
                )
              ],
            )
          : const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }
}

class _PreviewList extends ConsumerWidget {
  const _PreviewList({
    required this.title,
    required this.posts,
    required this.onViewMore,
  });

  final String title;
  final List<DanbooruPost> posts;
  final void Function() onViewMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          visualDensity: const VisualDensity(
            horizontal: -4,
            vertical: -4,
          ),
          trailing: TextButton(
            onPressed: onViewMore,
            child: const Text('View all'),
          ),
        ),
        PreviewPostList(
          posts: posts,
          onTap: (index) => goToDetailPage(
            context: context,
            posts: posts.toList(),
            initialIndex: index,
          ),
          imageUrl: (item) => item.url360x360,
        ),
      ],
    );
  }
}
