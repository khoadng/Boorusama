// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/favorites.dart';
import 'package:boorusama/boorus/danbooru/features/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/pages/favorites/modal_favorite_group_action.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/ui/booru_image.dart';
import 'package:boorusama/i18n.dart';

class FavoriteGroupsPage extends ConsumerWidget {
  const FavoriteGroupsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteGroups = ref.watch(danbooruFavoriteGroupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('favorite_groups.favorite_groups').tr(),
        actions: [
          IconButton(
            onPressed: () => goToFavoriteGroupCreatePage(context),
            icon: const FaIcon(FontAwesomeIcons.plus),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            if (favoriteGroups == null)
              _buildLoading()
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final group = favoriteGroups[index];

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
                            'favorite_groups.group_item_counter'
                                .plural(group.totalCount),
                          ),
                          if (!group.isPublic)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text('|'),
                            ),
                          if (!group.isPublic)
                            const Text('favorite_groups.private').tr(),
                        ],
                      ),
                      onTap: () {
                        goToFavoriteGroupDetailsPage(context, group);
                      },
                      leading: _Preview(group: group),
                      trailing: IconButton(
                        onPressed: () => _showEditSheet(
                          context,
                          ref,
                          group,
                        ),
                        icon: const Icon(Icons.more_vert),
                      ),
                    );
                  },
                  childCount: favoriteGroups.length,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(
      BuildContext context, WidgetRef ref, FavoriteGroup favGroup) {
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
                  ref
                      .read(danbooruFavoriteGroupsProvider.notifier)
                      .delete(group: favGroup);
                },
                child: const Text('generic.action.ok').tr(),
              ),
            ],
          ),
        ),
        onEdit: () => goToFavoriteGroupEditPage(context, favGroup),
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

class _Preview extends ConsumerWidget {
  const _Preview({
    required this.group,
  });

  final FavoriteGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preview = ref
        .watch(danbooruFavoriteGroupPreviewProvider(group.postIds.firstOrNull));

    return BooruImage(
      fit: BoxFit.cover,
      imageUrl: preview,
    );
  }
}
