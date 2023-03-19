// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/features/favorites/modal_favorite_group_action.dart';
import 'package:boorusama/core/ui/booru_image.dart';

class FavoriteGroupsPage extends StatelessWidget {
  const FavoriteGroupsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('favorite_groups.favorite_groups').tr(),
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
            return CustomScrollView(
              slivers: [
                if (state.loading) _buildLoading() else _buildList(state),
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
                ? const Text('favorite_groups.empty_group_notice').tr()
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
            title: Text(
              group.name.replaceAll('_', ' '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            subtitle: Row(
              children: [
                Text(
                  'favorite_groups.group_item_counter'.plural(group.totalCount),
                ),
                if (!group.isPublic)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('|'),
                  ),
                if (!group.isPublic) const Text('favorite_groups.private').tr(),
              ],
            ),
            onTap: () {
              final bloc = context.read<FavoriteGroupsBloc>();

              goToFavoriteGroupDetailsPage(context, group, bloc);
            },
            leading: state.previews.isNotEmpty && group.totalCount > 0
                ? BooruImage(
                    fit: BoxFit.cover,
                    imageUrl: state.previews[group.postIds.first] ?? '',
                  )
                : const BooruImage(imageUrl: ''),
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
                child: const Text('generic.action.cancel').tr(),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  bloc.add(FavoriteGroupsDeleted(
                    groupId: favGroup.id,
                  ));
                },
                child: const Text('generic.action.ok').tr(),
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
        padding: EdgeInsets.only(top: 24),
        child: Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}
