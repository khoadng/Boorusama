// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/saved_searches/saved_searches.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/generic_no_data_box.dart';

class SavedSearchPage extends ConsumerWidget {
  const SavedSearchPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchesAsync =
        ref.watch(danbooruSavedSearchesProvider(ref.watchConfig));

    return Scaffold(
      appBar: AppBar(
        title: const Text('saved_search.saved_search').tr(),
        actions: [
          IconButton(
            onPressed: () => goToSavedSearchCreatePage(context),
            icon: const Icon(Symbols.add),
          ),
        ],
      ),
      body: SafeArea(
        child: searchesAsync.when(
          data: (data) => _SuccessView(savedSearches: data),
          error: (error, stackTrace) => Center(
            child: Text(error.toString()),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
      ),
    );
  }
}

class _SuccessView extends ConsumerWidget {
  const _SuccessView({
    required this.savedSearches,
  });

  final List<SavedSearch> savedSearches;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.theme.hintColor,
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
                          icon: const Icon(Symbols.more_vert),
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
            .read(danbooruSavedSearchesProvider(ref.readConfig).notifier)
            .delete(savedSearch: savedSearch),
        onEdit: () => goToSavedSearchPatchPage(context, savedSearch),
      ),
    );
  }
}
