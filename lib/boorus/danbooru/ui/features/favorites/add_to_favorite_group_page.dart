// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/app.dart';
import 'package:boorusama/boorus/danbooru/application/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/posts/post.dart';
import 'package:boorusama/core/ui/booru_image.dart';
import 'package:boorusama/core/ui/search_bar.dart';

class AddToFavoriteGroupPage extends StatelessWidget {
  const AddToFavoriteGroupPage({
    super.key,
    required this.posts,
  });

  final List<Post> posts;

  @override
  Widget build(BuildContext context) {
    final state = context.select((FavoriteGroupsBloc bloc) => bloc.state);
    final bloc = context.read<FavoriteGroupsBloc>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'favorite_groups.add_to_group_dialog_title',
          style: Theme.of(context).textTheme.titleLarge,
        ).tr(),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
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
                    imageUrl: posts[index].isAnimated
                        ? posts[index].thumbnailImageUrl
                        : posts[index].sampleImageUrl,
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
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => goToFavoriteGroupCreatePage(
                  context,
                  bloc,
                  enableManualPostInput: false,
                ),
                child: const Text('favorite_groups.create').tr(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SearchBar(
              onChanged: (value) =>
                  bloc.add(FavoriteGroupsFiltered(pattern: value)),
            ),
          ),
          const SizedBox(height: 8),
          if (state.loading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            )
          else
            Expanded(
              child: ImplicitlyAnimatedList<FavoriteGroup>(
                items: state.filteredFavoriteGroups,
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
                      subtitle: Text(dateTimeToStringTimeAgo(group.updatedAt)),
                      trailing:
                          Text('favorite_groups.group_item_counter'.plural(
                        group.postIds.length,
                      )),
                      onTap: () => bloc.add(FavoriteGroupsItemAdded(
                        group: group,
                        postIds: posts.map((e) => e.id).toList(),
                        onFailure: (message, translatable) {
                          showSimpleSnackBar(
                            context: context,
                            duration: const Duration(seconds: 6),
                            content: translatable
                                ? Text(
                                    message,
                                  ).tr()
                                : Text(
                                    message,
                                  ),
                          );
                        },
                        onSuccess: (newGroup) {
                          showSimpleSnackBar(
                            context: context,
                            duration: const Duration(seconds: 3),
                            action: SnackBarAction(
                              label: 'favorite_groups.view_more_popup'.tr(),
                              onPressed: () {
                                if (navigatorKey.currentContext != null) {
                                  goToFavoriteGroupDetailsPage(
                                    navigatorKey.currentContext!,
                                    newGroup,
                                    bloc,
                                  );
                                }
                              },
                            ),
                            content: Text(
                              'favorite_groups.items_added_notification_popup'
                                  .tr()
                                  .replaceAll('{0}', '${posts.length}')
                                  .replaceAll(
                                    '{1}',
                                    group.name.replaceAll('_', ' '),
                                  ),
                            ),
                          );
                          Navigator.of(context).pop(true);
                        },
                      )),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
