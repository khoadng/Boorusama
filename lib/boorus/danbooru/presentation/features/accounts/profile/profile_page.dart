// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/profile/profile.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/profile/profile_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/favorites/favorites_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/posts/preview_post_list.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/presentation/widgets/slide_in_route.dart';
import 'package:boorusama/generated/i18n.dart';

final _profile = FutureProvider.autoDispose<Profile>((ref) async {
  final cancelToken = CancelToken();
  ref.onDispose(cancelToken.cancel);

  final repo = ref.watch(profileProvider);
  final profile = await repo.getProfile(cancelToken: cancelToken);

  ref.maintainState = true;

  return profile;
});

final _favorites = FutureProvider.autoDispose<List<Post>>((ref) async {
  final cancelToken = CancelToken();
  ref.onDispose(cancelToken.cancel);

  final repo = ref.watch(postProvider);
  final profile = await ref.watch(_profile.future);
  final favorites = await repo.getPosts("ordfav:${profile.name}", 1,
      limit: 10, cancelToken: cancelToken);

  return favorites;
});

class ProfilePage extends HookWidget {
  const ProfilePage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profile = useProvider(_profile);
    final favorites = useProvider(_favorites);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(I18n.of(context).profileProfile),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  context.read(authenticationStateNotifierProvider).logOut();
                  AppRouter.router.navigateTo(context, "/",
                      clearStack: true, replace: true);
                }),
          ],
        ),
        body: profile.maybeWhen(
          data: (profile) => CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    ListTile(
                      leading: Text("User ID"),
                      trailing: Text(
                        profile.id.toString(),
                      ),
                    ),
                    ListTile(
                      leading: Text("Level"),
                      trailing: Text(
                        profile.levelString,
                      ),
                    ),
                    ListTile(
                      leading: Text("Favorites"),
                      trailing: Text(
                        profile.favoriteCount.toString(),
                      ),
                    ),
                    ListTile(
                      leading: Text("Comments"),
                      trailing: Text(
                        profile.commentCount.toString(),
                      ),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Divider(
                  endIndent: 10,
                  indent: 10,
                ),
              ),
              SliverToBoxAdapter(
                child: ListTile(
                  leading: Text(
                    I18n.of(context).profileFavorites,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  trailing: TextButton(
                    onPressed: () => Navigator.of(context).push(SlideInRoute(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            SafeArea(child: FavoritesPage()))),
                    child: Text("See more"),
                  ),
                ),
              ),
              favorites.maybeWhen(
                data: (posts) => SliverToBoxAdapter(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: PreviewPostList(
                        posts: posts,
                        physics: const AlwaysScrollableScrollPhysics(),
                      ),
                    ),
                  ),
                ),
                orElse: () => SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ],
          ),
          orElse: () => Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
