// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/favorites/favorites_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/profile/profile_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/boorus/danbooru/domain/profile/profile.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/favorites/favorites_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/posts/preview_post_list.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/presentation/widgets/slide_in_route.dart';

class ProfilePage extends HookWidget {
  const ProfilePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      ReadContext(context).read<ProfileCubit>().getProfile();
    }, []);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('profile.profile'.tr()),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  BuildContextX(context)
                      .read(authenticationStateNotifierProvider)
                      .logOut();
                  AppRouter.router.navigateTo(context, "/",
                      clearStack: true, replace: true);
                }),
          ],
        ),
        body: SafeArea(
          child: BlocConsumer<ProfileCubit, AsyncLoadState<Profile>>(
              listener: (context, state) => state.status == LoadStatus.success
                  ? ReadContext(context)
                      .read<FavoritesCubit>()
                      .getUserFavoritePosts(state.data!.name)
                  : null,
              builder: (context, state) {
                if (state.status == LoadStatus.success) {
                  final profile = state.data!;
                  return CustomScrollView(
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
                            'profile.favorites'.tr(),
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          trailing: TextButton(
                            onPressed: () => Navigator.of(context).push(
                                SlideInRoute(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        FavoritesPage())),
                            child: Text("See more"),
                          ),
                        ),
                      ),
                      BlocBuilder<FavoritesCubit, AsyncLoadState<List<Post>>>(
                        builder: (context, state) {
                          if (state.status == LoadStatus.success) {
                            return SliverToBoxAdapter(
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                child: Padding(
                                  padding: EdgeInsets.all(4),
                                  child: PreviewPostList(
                                    posts: state.data!,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                  ),
                                ),
                              ),
                            );
                          } else if (state.status == LoadStatus.failure) {
                            return SizedBox.shrink();
                          } else {
                            return SliverToBoxAdapter(
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                        },
                      )
                    ],
                  );
                } else if (state.status == LoadStatus.failure) {
                  return Center(
                    child: Text("Fail to load profile"),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        ),
      ),
    );
  }
}
