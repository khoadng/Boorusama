// Flutter imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/ui/pagination.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class FavoriteGroupsPage extends StatelessWidget {
  const FavoriteGroupsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Group'),
        actions: [
          IconButton(
            onPressed: () {
              final bloc = context.read<FavoriteGroupsBloc>();
              goToFavoriteGroupCreatePage(context, bloc);
            },
            icon: const FaIcon(FontAwesomeIcons.plus),
          ),
        ],
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
            trailing: IconButton(
              onPressed: () => _showEditSheet(
                context,
                group,
              ),
              icon: const Icon(Icons.more_vert),
            ),
          );
        },
        childCount: state.favoriteGroups.length,
      ),
    );
  }

  void _showEditSheet(BuildContext context, FavoriteGroup favGroup) {
    final bloc = context.read<FavoriteGroupsBloc>();
    showMaterialModalBottomSheet(
      context: context,
      builder: (_) => ModalFavoriteGroupAction(
        onDelete: () => bloc.add(FavoriteGroupsDeleted(
          groupId: favGroup.id,
        )),
        onEdit: () => print('edit'),
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

// ignore: prefer-single-widget-per-file
class ModalFavoriteGroupAction extends StatelessWidget {
  const ModalFavoriteGroupAction({
    super.key,
    this.onEdit,
    this.onDelete,
  });

  final void Function()? onEdit;
  final void Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.background,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('generic.action.edit').tr(),
              leading: const Icon(Icons.edit),
              onTap: () {
                Navigator.of(context).pop();
                onEdit?.call();
              },
            ),
            ListTile(
              title: const Text('generic.action.delete').tr(),
              leading: const Icon(Icons.clear),
              onTap: () {
                Navigator.of(context).pop();
                onDelete?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}
