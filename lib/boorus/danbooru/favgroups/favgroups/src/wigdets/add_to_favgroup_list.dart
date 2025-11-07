// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../core/configs/config/types.dart';
import '../../../../../../foundation/animations/constants.dart';
import '../../../../../../foundation/toast.dart';
import '../../../../posts/post/types.dart';
import '../../types.dart';
import '../providers/favorite_groups_filterable_notifier.dart';
import '../providers/favorite_groups_notifier.dart';

class AddToFavgroupList extends ConsumerWidget {
  const AddToFavgroupList({
    required this.posts,
    super.key,
  });

  final List<DanbooruPost> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;
    final filteredGroups = ref.watch(
      danbooruFavoriteGroupFilterableProvider(config),
    );

    return filteredGroups.toOption().fold(
      () => const Padding(
        padding: EdgeInsets.all(8),
        child: Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      ),
      (groups) => groups.isEmpty
          ? const Center(child: Text('Empty'))
          : _buildList(groups, context, ref, config),
    );
  }

  Widget _buildList(
    List<DanbooruFavoriteGroup> groups,
    BuildContext context,
    WidgetRef ref,
    BooruConfigSearch config,
  ) {
    return ImplicitlyAnimatedList<DanbooruFavoriteGroup>(
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
              group.name.replaceAll('_', ' '),
            ),
            subtitle: Text(
              group.updatedAt.fuzzify(locale: Localizations.localeOf(context)),
            ),
            trailing: Text(
              context.t.favorite_groups.group_item_counter(
                n: group.postIds.length,
              ),
            ),
            onTap: () {
              ref
                  .read(danbooruFavoriteGroupsProvider(config).notifier)
                  .addToGroup(
                    context: context,
                    group: group,
                    postIds: posts.map((e) => e.id).toList(),
                    onFailure: (message) {
                      showSimpleSnackBar(
                        context: context,
                        duration: AppDurations.extraLongToast,
                        content: Text(message),
                      );
                    },
                    onSuccess: (newGroup) {
                      showSimpleSnackBar(
                        context: context,
                        duration: AppDurations.longToast,
                        content: Text(
                          context
                              .t
                              .favorite_groups
                              .items_added_notification_popup
                              .replaceAll('{0}', '${posts.length}')
                              .replaceAll(
                                '{1}',
                                group.name.replaceAll('_', ' '),
                              ),
                        ),
                      );
                      Navigator.of(context).pop(true);
                    },
                  );
            },
          ),
        );
      },
    );
  }
}
