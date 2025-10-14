// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../core/search/search/routes.dart';
import '../../../../../../core/themes/theme/types.dart';
import '../../../../../../core/widgets/generic_no_data_box.dart';
import '../../../saved_search/providers.dart';
import '../../../saved_search/routes.dart';
import '../../../saved_search/types.dart';
import 'saved_search_quick_edit_sheet.dart';

class SavedSearchPage extends ConsumerWidget {
  const SavedSearchPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchesAsync = ref.watch(
      danbooruSavedSearchesProvider(ref.watchConfigAuth),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.saved_search.saved_search),
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
            text: context.t.saved_search.empty_saved_search,
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
                        context.t.saved_search
                            .saved_search_counter(n: savedSearches.length)
                            .toUpperCase(),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.hintColor,
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
                          ref,
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
    showModalBottomSheet(
      context: context,
      routeSettings: const RouteSettings(name: 'saved_search_action_select'),
      builder: (_) => SavedSearchQuickEditSheet(
        savedSearch: savedSearch,
      ),
    );
  }
}
