// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/theme/theme_utils.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'edit_favorite_tag_sheet.dart';
import 'favorite_tag_config_sheet.dart';
import 'favorite_tag_label_chip.dart';
import 'favorite_tag_labels_page.dart';

const kFavoriteTagsSelectedLabelKey = 'favorite_tags_selected_label';

enum FavoriteTagsSortType {
  recentlyAdded,
  recentlyUpdated,
  nameAZ,
  nameZA,
}

final selectedFavoriteTagQueryProvider =
    StateProvider.autoDispose<String>((ref) {
  return '';
});

final selectedFavoriteTagsSortTypeProvider =
    StateProvider.autoDispose<FavoriteTagsSortType>((ref) {
  return FavoriteTagsSortType.recentlyAdded;
});

class FavoriteTagsPage extends ConsumerWidget {
  const FavoriteTagsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesNotifier = ref.watch(favoriteTagsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite tags'),
        actions: [
          IconButton(
            onPressed: () {
              context.navigator.push(
                CupertinoPageRoute(
                  builder: (context) => const FavoriteTagLabelsPage(),
                ),
              );
            },
            icon: const Icon(
              FontAwesomeIcons.tags,
              fill: 1,
              size: 20,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          goToQuickSearchPage(
            context,
            ref: ref,
            onSubmitted: (context, text) {
              context.navigator.pop();
              favoritesNotifier.add(
                text,
                onDuplicate: (tag) => showErrorToast(
                  '$tag already exists',
                ),
                // labels: [
                //   selectedLabel,
                // ],
              );
            },
            onSelected: (tag) => favoritesNotifier.add(
              tag.value,
              onDuplicate: (tag) => showErrorToast(
                '$tag already exists',
              ),
              // labels: [
              //   selectedLabel,
              // ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: FavoriteTagsFilterScope(
        sortType: ref.watch(selectedFavoriteTagsSortTypeProvider),
        filterQuery: ref.watch(selectedFavoriteTagQueryProvider),
        builder: (context, tags, labels, selected) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: BooruSearchBar(
                      hintText: 'Filter...',
                      onChanged: (value) => ref
                          .read(selectedFavoriteTagQueryProvider.notifier)
                          .state = value,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showMaterialModalBottomSheet(
                        context: context,
                        backgroundColor: context.colorScheme.secondaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        builder: (context) => FavoriteTagConfigSheet(
                          onSorted: (value) {
                            ref
                                .read(selectedFavoriteTagsSortTypeProvider
                                    .notifier)
                                .state = value;
                          },
                        ),
                      );
                    },
                    icon: const Icon(
                      FontAwesomeIcons.sliders,
                      fill: 1,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            tags.isNotEmpty
                ? Expanded(
                    child: _buildTags(tags, ref),
                  )
                : const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No tags'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTags(
    List<FavoriteTag> tags,
    WidgetRef ref,
  ) {
    return ListView.builder(
      itemCount: tags.length,
      itemBuilder: (context, index) {
        final tag = tags[index];
        final labels = tag.labels ?? <String>[];

        return ListTile(
          title: Text(tag.name),
          contentPadding: const EdgeInsets.only(
            left: 16,
            right: 4,
          ),
          subtitle: labels.isNotEmpty
              ? Container(
                  margin: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final label in labels)
                        FavoriteTagLabelChip(
                          label: label,
                        ),
                    ],
                  ),
                )
              : null,
          trailing: BooruPopupMenuButton(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  final tag = tags[index];
                  ref.read(favoriteTagsProvider.notifier).remove(tag.name);
                  break;
                case 'edit':
                  showMaterialModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    builder: (context) => EditFavoriteTagSheet(
                      initialValue: tag,
                      title: tag.name,
                      onSubmit: (tag) {
                        ref.read(favoriteTagsProvider.notifier).update(
                              tag.name,
                              tag,
                            );
                      },
                    ),
                  );
                  break;
              }
            },
            itemBuilder: const {
              'edit': Text('Edit'),
              'delete': Text('Delete'),
            },
          ),
        );
      },
    );
  }
}
