// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/favorites.dart';
import 'package:boorusama/boorus/danbooru/application/profile/profile.dart';
import 'package:boorusama/boorus/danbooru/domain/profiles/profile.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/application/authentication.dart';
import 'package:boorusama/core/application/common.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('profile.profile'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthenticationCubit>().logOut();
              goToHomePage(context, replace: true);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<ProfileCubit, AsyncLoadState<Profile>>(
          listener: (context, state) => state.status == LoadStatus.success
              ? context
                  .read<FavoritesCubit>()
                  .getUserFavoritePosts(state.data!.name)
              : null,
          builder: (context, state) {
            if (state.status == LoadStatus.success) {
              final profile = state.data!;

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        ListTile(
                          dense: true,
                          leading: const Text('profile.user_id').tr(),
                          trailing: Text(
                            profile.id.toString(),
                          ),
                        ),
                        ListTile(
                          dense: true,
                          leading: const Text('profile.level').tr(),
                          trailing: Text(
                            profile.levelString,
                          ),
                        ),
                        ListTile(
                          dense: true,
                          leading: const Text('profile.favorites_count').tr(),
                          trailing: Text(
                            profile.favoriteCount.toString(),
                          ),
                        ),
                        ListTile(
                          dense: true,
                          leading: const Text('profile.comments_count').tr(),
                          trailing: Text(
                            profile.commentCount.toString(),
                          ),
                        ),
                      ],
                    ),
                  ),
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
          },
        ),
      ),
    );
  }
}
