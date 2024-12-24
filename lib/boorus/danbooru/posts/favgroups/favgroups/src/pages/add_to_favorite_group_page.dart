// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../../../core/configs/ref.dart';
import '../../../../../../../core/images/booru_image.dart';
import '../../../../../../../core/search/search/widgets.dart';
import '../../../../post/post.dart';
import '../providers/favorite_groups_filterable_notifier.dart';
import '../routes/route_utils.dart';
import '../wigdets/add_to_favgroup_list.dart';

class AddToFavoriteGroupPage extends ConsumerWidget {
  const AddToFavoriteGroupPage({
    required this.posts,
    super.key,
  });

  final List<DanbooruPost> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'favorite_groups.add_to_group_dialog_title',
          style: Theme.of(context).textTheme.titleLarge,
        ).tr(),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                    imageUrl: posts[index].url720x720,
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              trailing: FilledButton(
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => goToFavoriteGroupCreatePage(
                  context,
                  enableManualPostInput: false,
                ),
                child: const Text('favorite_groups.create').tr(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: BooruSearchBar(
              onChanged: (value) => ref
                  .read(
                    danbooruFavoriteGroupFilterableProvider(config).notifier,
                  )
                  .filter(value),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: AddToFavgroupList(posts: posts)),
        ],
      ),
    );
  }
}
