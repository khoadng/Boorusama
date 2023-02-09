// Flutter imports:
import 'package:boorusama/boorus/danbooru/application/user/current_user_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';
import 'package:boorusama/core/ui/warning_container.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/router.dart';

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
        child: BlocBuilder<FavoriteGroupsBloc, FavoriteGroupsState>(
          builder: (context, state) {
            return Column(
              children: [
                BlocBuilder<CurrentUserBloc, CurrentUserState>(
                  builder: (context, state) {
                    return state.user != null &&
                            !isBooruGoldPlusAccount(state.user!.level)
                        ? WarningContainer(
                            contentBuilder: (context) =>
                                const Text('favorite_groups.max_limit_warning')
                                    .tr(),
                          )
                        : const SizedBox.shrink();
                  },
                ),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      if (state.loading) _buildLoading() else _buildList(state),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(FavoriteGroupsState state) {
    if (state.favoriteGroups.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 42),
          child: Center(
            child: state.page == 1
                ? const Text('No favorite groups')
                : const Text('No data'),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final group = state.favoriteGroups[index];

          return ListTile(
            title: Row(
              children: [
                if (!group.isPublic)
                  const Icon(
                    Icons.lock,
                    size: 14,
                  ),
                if (!group.isPublic) const SizedBox(width: 4),
                Text(group.name.replaceAll('_', ' ')),
              ],
            ),
            subtitle: Text(
              '${group.totalCount} posts',
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
        onDelete: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: const Text('favorite_groups.detete_confirmation').tr(),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onBackground,
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  bloc.add(FavoriteGroupsDeleted(
                    groupId: favGroup.id,
                  ));
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ),
        onEdit: () => goToFavoriteGroupEditPage(context, bloc, favGroup),
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
