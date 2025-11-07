// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../../core/configs/auth/widgets.dart';
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../core/images/booru_image.dart';
import '../../../../../../core/themes/theme/types.dart';
import '../../../details/routes.dart';
import '../../../favgroups/providers.dart';
import '../../../favgroups/routes.dart';
import '../../../favgroups/types.dart';
import '../providers/post_previews_notifier.dart';
import '../routes/internal_routes.dart';

class FavoriteGroupsPage extends ConsumerWidget {
  const FavoriteGroupsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BooruConfigAuthFailsafe(
      builder: (_) => const FavoriteGroupsPageInternal(),
    );
  }
}

class FavoriteGroupsPageInternal extends ConsumerWidget {
  const FavoriteGroupsPageInternal({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;
    final favoriteGroups = ref.watch(danbooruFavoriteGroupsProvider(config));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.favorite_groups.favorite_groups),
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
            else if (favoriteGroups.isEmpty)
              _buildEmpty(context)
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            context.t.favorite_groups.group_item_counter(
                              n: group.totalCount,
                            ),
                          ),
                          if (!group.isPublic)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text('|'),
                            ),
                          if (!group.isPublic)
                            Text(context.t.favorite_groups.private),
                        ],
                      ),
                      onTap: () {
                        goToFavoriteGroupDetailsPage(ref, group);
                      },
                      leading: _Preview(group: group),
                      trailing: IconButton(
                        onPressed: () => showFavgroupEditSheet(
                          context,
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

  Widget _buildLoading() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(top: 24),
        child: Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Center(
          child: Text(
            context.t.favorite_groups.empty_group_notice,
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.hintColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _Preview extends ConsumerWidget {
  const _Preview({
    required this.group,
  });

  final DanbooruFavoriteGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preview = ref.watch(
      danbooruFavoriteGroupPreviewProvider(group.postIds.firstOrNull),
    );

    return BooruImage(
      config: ref.watchConfigAuth,
      fit: BoxFit.cover,
      imageUrl: preview,
    );
  }
}
