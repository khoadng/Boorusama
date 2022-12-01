// Flutter imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/ui/error_box.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/favorites/favorites.dart';

class FavoriteGroupsPage extends StatelessWidget {
  const FavoriteGroupsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Group'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            BlocBuilder<FavoriteGroupsBloc, FavoriteGroupsState>(
              builder: (context, state) {
                switch (state.status) {
                  case LoadStatus.initial:
                  case LoadStatus.loading:
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    );
                  case LoadStatus.success:
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final group = state.favoriteGroups[index];

                          return ListTile(
                            title: Text(group.name.replaceAll('_', ' ')),
                            subtitle: Text(
                              '${group.creator.name} - ${group.totalCount} posts',
                            ),
                            onTap: () => AppRouter.router.navigateTo(
                              context,
                              '/posts/search',
                              routeSettings: RouteSettings(arguments: [
                                state.favoriteGroupDetailQueryOf(index),
                              ]),
                            ),
                          );
                        },
                        childCount: state.favoriteGroups.length,
                      ),
                    );
                  case LoadStatus.failure:
                    return const SliverToBoxAdapter(child: ErrorBox());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
