// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/ui/pagination.dart';

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
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  BlocBuilder<FavoriteGroupsBloc, FavoriteGroupsState>(
                    builder: (context, state) {
                      return state.loading
                          ? _buildLoading()
                          : _buildList(state);
                    },
                  ),
                ],
              ),
            ),
            const _PageSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildList(FavoriteGroupsState state) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final group = state.favoriteGroups[index];

          return ListTile(
            title: Text(group.name.replaceAll('_', ' ')),
            subtitle: Text(
              '${group.creator.name} - ${group.totalCount} posts',
            ),
            onTap: () => goToFavoriteGroupDetailsPage(context, group),
          );
        },
        childCount: state.favoriteGroups.length,
      ),
    );
  }

  Widget _buildLoading() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(top: 8),
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}

class _PageSelector extends StatelessWidget {
  const _PageSelector();

  @override
  Widget build(BuildContext context) {
    final page = context.select((FavoriteGroupsBloc bloc) => bloc.state.page);

    return PageSelector(
      currentPage: page,
      itemPerPage: 50,
      onPrevious: page > 1 ? () => _fetch(context, page - 1) : null,
      onNext: () => _fetch(context, page + 1),
      onPageSelect: (page) => _fetch(context, page),
    );
  }

  void _fetch(BuildContext context, int page) {
    return context
        .read<FavoriteGroupsBloc>()
        .add(FavoriteGroupsFetched(page: page));
  }
}
