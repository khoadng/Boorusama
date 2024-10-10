// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/clients/szurubooru/types/types.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/time.dart';
import 'providers.dart';

final szurubooruPoolsProvider =
    FutureProvider.autoDispose.family<List<PoolDto>, BooruConfig>(
  (ref, config) {
    final client = ref.read(szurubooruClientProvider(config));

    return client.getPools(limit: 100);
  },
);

class SzurubooruAddToPoolPage extends ConsumerWidget {
  const SzurubooruAddToPoolPage({
    super.key,
    required this.posts,
  });

  final List<Post> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final config = ref.watchConfig;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add to pool',
          style: context.textTheme.titleLarge,
        ).tr(),
      ),
      backgroundColor: context.colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: BooruImage(
                    imageUrl: posts[index].thumbnailImageUrl,
                    aspectRatio: posts[index].aspectRatio,
                  ),
                ),
                itemCount: posts.length,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListTile(
              visualDensity: VisualDensity.compact,
              title: Text(
                'favorite_groups.add_to'.tr().toUpperCase(),
                style: context.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              // trailing: FilledButton(
              //   style: FilledButton.styleFrom(
              //     visualDensity: VisualDensity.compact,
              //   ),
              //   onPressed: () => goToFavoriteGroupCreatePage(
              //     context,
              //     enableManualPostInput: false,
              //   ),
              //   child: const Text('favorite_groups.create').tr(),
              // ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 12),
          //   child: BooruSearchBar(
          //     onChanged: (value) => ref
          //         .read(
          //             danbooruFavoriteGroupFilterableProvider(config).notifier)
          //         .filter(value),
          //   ),
          // ),
          // const SizedBox(height: 8),
          Expanded(child: _FavoriteGroupList(posts: posts)),
        ],
      ),
    );
  }
}

class _FavoriteGroupList extends ConsumerWidget {
  const _FavoriteGroupList({
    required this.posts,
  });

  final List<Post> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;

    return ref.watch(szurubooruPoolsProvider(config)).when(
          data: (pools) => _buildList(pools, context, ref, config),
          error: (error, _) => Center(
            child: Text(error.toString()),
          ),
          loading: () => const Padding(
            padding: EdgeInsets.all(8),
            child: Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          ),
        );

    // return filteredGroups.toOption().fold(
    //       () => const Padding(
    //         padding: EdgeInsets.all(8),
    //         child: Center(
    //           child: CircularProgressIndicator.adaptive(),
    //         ),
    //       ),
    //       (groups) => groups.isEmpty
    //           ? const Center(child: Text('Empty'))
    //           : _buildList(groups, context, ref, config),
    //     );
  }

  Widget _buildList(
    List<PoolDto> groups,
    BuildContext context,
    WidgetRef ref,
    BooruConfig config,
  ) {
    return ImplicitlyAnimatedList<PoolDto>(
      items: groups,
      controller: ModalScrollController.of(context),
      areItemsTheSame: (oldItem, newItem) => oldItem == newItem,
      insertDuration: const Duration(milliseconds: 250),
      removeDuration: const Duration(milliseconds: 250),
      itemBuilder: (_, animation, group, index) {
        return SizeFadeTransition(
          sizeFraction: 0.7,
          curve: Curves.easeInOut,
          animation: animation,
          child: ListTile(
            title: Text(
              group.names?.firstOrNull ?? '???',
            ),
            subtitle: Text(
              DateTime.tryParse(group.creationTime ?? '')
                      ?.fuzzify(locale: Localizations.localeOf(context)) ??
                  '???',
            ),
            trailing: Text('favorite_groups.group_item_counter'.plural(
              group.posts?.length ?? 0,
            )),
            onTap: () async {
              final id = group.id;
              final postIds =
                  group.posts?.map((e) => e.id).whereNotNull().toList() ?? [];
              final version = group.version;

              if (id == null || postIds.isEmpty || version == null) {
                return;
              }

              final newIds = [
                ...postIds,
              ];

              for (final post in posts) {
                if (!newIds.contains(post.id)) {
                  newIds.add(post.id);
                }
              }

              final navigator = Navigator.of(context);

              await ref.read(szurubooruClientProvider(config)).updatePool(
                    id,
                    PoolUpdateRequest(
                      version: version,
                      postIds: newIds,
                    ),
                  );

              navigator.pop();
            },
          ),
        );
      },
    );
  }
}
