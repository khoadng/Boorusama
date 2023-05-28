// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/saved_searches.dart';
import 'package:boorusama/boorus/danbooru/domain/saved_searches.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/ui/generic_no_data_box.dart';
import 'widgets/modal_saved_search_action.dart';

class SavedSearchPage extends ConsumerWidget {
  const SavedSearchPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('saved_search.saved_search').tr(),
        actions: [
          IconButton(
            onPressed: () => goToSavedSearchCreatePage(ref, context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: const SafeArea(
        child: _SuccessView(),
      ),
    );
  }
}

class _SuccessView extends ConsumerWidget {
  const _SuccessView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedSearches = ref.watch(danbooruSavedSearchesProvider);

    if (savedSearches == null) {
      return const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }

    return savedSearches.isEmpty
        ? GenericNoDataBox(
            text: 'saved_search.empty_saved_search'.tr(),
          )
        : CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 15)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'saved_search.saved_search_counter'
                            .plural(savedSearches.length)
                            .toUpperCase(),
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverImplicitlyAnimatedList(
                items: savedSearches,
                areItemsTheSame: (oldItem, newItem) => oldItem == newItem,
                itemBuilder: (context, animation, savedSearch, i) => ListTile(
                  title: Text(savedSearch.labels.join(' ')),
                  subtitle: Text(savedSearch.query),
                  trailing: savedSearch.readOnly
                      ? null
                      : IconButton(
                          onPressed: () => _showEditSheet(
                            ref,
                            context,
                            savedSearch,
                          ),
                          icon: const Icon(Icons.more_vert),
                        ),
                  onTap: savedSearch.labels.isNotEmpty
                      ? () => goToSearchPage(
                            context,
                            tag: 'search:${savedSearch.labels.first}',
                          )
                      : null,
                  onLongPress: savedSearch.readOnly
                      ? null
                      : () => _showEditSheet(ref, context, savedSearch),
                ),
              ),
            ],
          );
  }

  void _showEditSheet(
    WidgetRef ref,
    BuildContext context,
    SavedSearch savedSearch,
  ) {
    showMaterialModalBottomSheet(
      context: context,
      builder: (_) => ModalSavedSearchAction(
        onDelete: () => ref
            .read(danbooruSavedSearchesProvider.notifier)
            .delete(savedSearch: savedSearch),
        onEdit: () => goToSavedSearchPatchPage(ref, context, savedSearch),
      ),
    );
  }
}
