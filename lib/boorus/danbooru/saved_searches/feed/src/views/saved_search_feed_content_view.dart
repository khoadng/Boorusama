// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/posts/listing/widgets.dart';
import '../../../../../../core/themes/theme/types.dart';
import '../../../../posts/listing/widgets.dart';
import '../../../../posts/post/providers.dart';
import '../../../saved_search/routes.dart';
import '../../../saved_search/saved_search.dart';
import '../widgets/saved_search_context_menu.dart';

class SavedSearchFeedContentView extends ConsumerStatefulWidget {
  const SavedSearchFeedContentView({
    required this.searches,
    super.key,
  });

  final List<SavedSearch> searches;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SavedSearchFeedContentViewState();
}

class _SavedSearchFeedContentViewState
    extends ConsumerState<SavedSearchFeedContentView> {
  var _selectedSearch = SavedSearch.all();
  late var searches = widget.searches;

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigSearch;

    return PostScope(
      fetcher: (page) => ref
          .read(danbooruPostRepoProvider(config))
          .getPosts(_selectedSearch.toQuery(), page),
      builder: (context, controller) => PostGrid(
        controller: controller,
        itemBuilder: (context, index, scrollController, useHero) =>
            DefaultDanbooruImageGridItem(
              index: index,
              autoScrollController: scrollController,
              controller: controller,
              useHero: useHero,
            ),
        sliverHeaders: [
          SliverAppBar(
            title: Text(context.t.saved_search.saved_search_feed),
            floating: true,
            actions: [
              IconButton(
                onPressed: () => goToSavedSearchEditPage(ref),
                icon: const Icon(
                  Symbols.settings,
                  fill: 1,
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
              height: 50,
              child: _SavedSearchList(
                searches: [
                  SavedSearch.all(),
                  ...searches,
                ],
                selectedSearch: _selectedSearch,
                onSearchChanged: (search) {
                  setState(() {
                    _selectedSearch = search;
                    controller.refresh();
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedSearchList extends ConsumerWidget {
  const _SavedSearchList({
    required this.searches,
    required this.selectedSearch,
    required this.onSearchChanged,
  });

  final List<SavedSearch> searches;
  final SavedSearch selectedSearch;
  final void Function(SavedSearch search) onSearchChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: searches.length,
      itemBuilder: (context, index) => _buildChip(
        context,
        searches[index],
      ),
    );
  }

  Widget _buildChip(BuildContext context, SavedSearch search) {
    final isSelected = selectedSearch == search;

    final text = search.labels.firstOption;

    return SavedSearchContextMenu(
      search: search,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ChoiceChip(
          selected: isSelected,
          onSelected: (selected) {
            if (!isSelected) {
              onSearchChanged(search);
            }
          },
          padding: EdgeInsets.symmetric(
            vertical: 4,
            horizontal: text.fold(
              () => 12,
              (text) => text.length < 4 ? 12 : 4,
            ),
          ),
          labelPadding: const EdgeInsets.all(1),
          visualDensity: VisualDensity.compact,
          side: BorderSide(
            width: 0.5,
            color: Theme.of(context).colorScheme.hintColor,
          ),
          label: Text(
            text.fold(
              () => '<empty>',
              (text) => text.replaceAll('_', ' '),
            ),
            overflow: TextOverflow.fade,
          ),
        ),
      ),
    );
  }
}
