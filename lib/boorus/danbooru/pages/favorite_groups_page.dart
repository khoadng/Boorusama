// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/string.dart';
import 'widgets/favorites/modal_favorite_group_action.dart';

class FavoriteGroupsPage extends ConsumerWidget {
  const FavoriteGroupsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final favoriteGroups = ref.watch(danbooruFavoriteGroupsProvider(config));

    return Scaffold(
      appBar: AppBar(
        title: const Text('favorite_groups.favorite_groups').tr(),
        actions: [
          IconButton(
            onPressed: () => goToFavoriteGroupCreatePage(context),
            icon: const Icon(Symbols.add),
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
                        group.name.replaceUnderscoreWithSpace(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
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
                          config,
                        ),
                        icon: const Icon(Symbols.more_vert),
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
    BuildContext context,
    WidgetRef ref,
    FavoriteGroup favGroup,
    BooruConfig config,
  ) {
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
                  foregroundColor: context.colorScheme.onSurface,
                ),
                onPressed: () => context.navigator.pop(),
                child: const Text('generic.action.cancel').tr(),
              ),
              FilledButton(
                onPressed: () {
                  context.navigator.pop();
                  ref
                      .read(danbooruFavoriteGroupsProvider(config).notifier)
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
