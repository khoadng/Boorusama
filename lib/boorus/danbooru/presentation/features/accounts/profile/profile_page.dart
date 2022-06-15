// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/favorites/favorites_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/profile/profile_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/boorus/danbooru/domain/profile/profile.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/posts/preview_post_list.dart';
import 'package:boorusama/boorus/danbooru/router.dart';

class ProfilePage extends HookWidget {
  const ProfilePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      ReadContext(context).read<ProfileCubit>().getProfile();
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: Text('profile.profile'.tr()),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                ReadContext(context).read<AuthenticationCubit>().logOut();
                AppRouter.router
                    .navigateTo(context, '/', clearStack: true, replace: true);
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
                            leading: const Text('User ID'),
                            trailing: Text(
                              profile.id.toString(),
                            ),
                          ),
                          ListTile(
                            leading: const Text('Level'),
                            trailing: Text(
                              profile.levelString,
                            ),
                          ),
                          ListTile(
                            leading: const Text('Favorites'),
                            trailing: Text(
                              profile.favoriteCount.toString(),
                            ),
                          ),
                          ListTile(
                            leading: const Text('Comments'),
                            trailing: Text(
                              profile.commentCount.toString(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SliverToBoxAdapter(
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
                          onPressed: () => AppRouter.router.navigateTo(
                              context, '/favorites',
                              routeSettings:
                                  RouteSettings(arguments: [profile.name])),
                          child: const Text('See more'),
                        ),
                      ),
                    ),
                    BlocBuilder<FavoritesCubit, AsyncLoadState<List<Post>>>(
                      builder: (context, state) {
                        if (state.status == LoadStatus.success) {
                          return SliverToBoxAdapter(
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.2,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: PreviewPostList(
                                  posts: state.data!,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                ),
                              ),
                            ),
                          );
                        } else if (state.status == LoadStatus.failure) {
                          return const SizedBox.shrink();
                        } else {
                          return const SliverToBoxAdapter(
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
                return const Center(
                  child: Text('Fail to load profile'),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }
}
