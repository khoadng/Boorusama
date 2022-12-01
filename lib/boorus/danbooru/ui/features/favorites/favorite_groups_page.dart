// Flutter imports:
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
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            BlocBuilder<FavoriteGroupsBloc, FavoriteGroupsState>(
              builder: (context, state) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final group = state.favoriteGroups[index];

                      return ListTile(
                        title: Text(group.name),
                        subtitle: Text(group.creator.name),
                      );
                    },
                    childCount: state.favoriteGroups.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
