// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../core/widgets/widgets.dart';
import '../../../../../foundation/toast.dart';
import '../../../../search/search/routes.dart';
import '../../../../search/search/widgets.dart';
import '../providers/favorite_tags_notifier.dart';
import '../providers/local_providers.dart';
import '../types/favorite_tag.dart';
import '../widgets/favorite_tag_label_chip.dart';
import '../widgets/favorite_tags_filter_scope.dart';
import 'edit_favorite_tag_sheet.dart';
import 'favorite_tag_config_sheet.dart';
import 'favorite_tag_labels_page.dart';

const kFavoriteTagsSelectedLabelKey = 'favorite_tags_selected_label';

class FavoriteTagsPage extends ConsumerWidget {
  const FavoriteTagsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesNotifier = ref.watch(favoriteTagsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.favorite_tags.favorite_tags),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  settings: const RouteSettings(
                    name: 'favorite_tag_labels',
                  ),
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
            onSubmitted: (context, text, isRaw) {
              Navigator.of(context).pop();
              favoritesNotifier.add(
                text,
                onDuplicate: (tag) => showErrorToast(
                  context,
                  '$tag already exists',
                ),
                isRaw: isRaw,
                // labels: [
                //   selectedLabel,
                // ],
              );
            },
            onSelected: (tag, isRaw) => favoritesNotifier.add(
              tag,
              onDuplicate: (tag) => showErrorToast(
                context,
                '$tag already exists',
              ),
              isRaw: isRaw,
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
                      hintText: context.t.search.hint,
                      onChanged: (value) =>
                          ref
                                  .read(
                                    selectedFavoriteTagQueryProvider.notifier,
                                  )
                                  .state =
                              value,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        routeSettings: const RouteSettings(
                          name: 'favorite_tag_config',
                        ),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        builder: (context) => FavoriteTagConfigSheet(
                          onSorted: (value) {
                            ref
                                    .read(
                                      selectedFavoriteTagsSortTypeProvider
                                          .notifier,
                                    )
                                    .state =
                                value;
                          },
                        ),
                      );
                    },
                    icon: const Icon(
                      Symbols.tune,
                      fill: 1,
                    ),
                  ),
                ],
              ),
            ),
            if (tags.isNotEmpty)
              Expanded(
                child: _buildTags(tags, ref),
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(context.t.generic.errors.no_data),
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
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
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
          onTap: () {
            goToSearchPage(
              ref,
              tag: tag.name,
              queryType: tag.queryType,
            );
          },
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
            items: [
              BooruPopupMenuItem(
                title: Text(context.t.generic.action.edit),
                icon: const Icon(Icons.edit),
                onTap: () {
                  showBooruModalBottomSheet(
                    context: context,
                    routeSettings: const RouteSettings(
                      name: 'edit_favorite_tag',
                    ),
                    resizeToAvoidBottomInset: true,
                    builder: (context) => EditFavoriteTagSheet(
                      initialValue: tag,
                      title: tag.name,
                      onSubmit: (tag) {
                        ref
                            .read(favoriteTagsProvider.notifier)
                            .update(
                              tag.name,
                              tag,
                            );
                      },
                    ),
                  );
                },
              ),
              BooruPopupMenuItem(
                title: Text(context.t.generic.action.delete),
                icon: const Icon(Icons.delete),
                onTap: () {
                  ref.read(favoriteTagsProvider.notifier).remove(tag.name);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
