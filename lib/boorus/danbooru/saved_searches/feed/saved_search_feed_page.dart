// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/posts/listing/widgets.dart';
import 'package:boorusama/boorus/danbooru/posts/post/providers.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/configs/failsafe.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/posts/listing/widgets.dart';
import 'package:boorusama/core/tags/tag/widgets.dart';
import 'package:boorusama/core/theme.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/router.dart';
import '../_shared/saved_searches_notifier.dart';
import '../save_search/saved_search.dart';
import 'saved_search_landing_view.dart';

class SavedSearchFeedPage extends ConsumerWidget {
  const SavedSearchFeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BooruConfigAuthFailsafe(
      child: const SavedSearchFeedPageInternal(),
    );
  }
}

class SavedSearchFeedPageInternal extends ConsumerStatefulWidget {
  const SavedSearchFeedPageInternal({
    super.key,
  });

  @override
  ConsumerState<SavedSearchFeedPageInternal> createState() =>
      _SavedSearchFeedPageState();
}

class _SavedSearchFeedPageState
    extends ConsumerState<SavedSearchFeedPageInternal> {
  var _selectedSearch = SavedSearch.all();

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigAuth;

    return CustomContextMenuOverlay(
      child: ref.watch(danbooruSavedSearchesProvider(config)).when(
            data: (searches) => searches.isNotEmpty
                ? _buildContent(searches)
                : const SavedSearchLandingView(),
            error: (error, stackTrace) => const Scaffold(
              body: ErrorBox(),
            ),
            loading: () => const Scaffold(
              body: Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
          ),
    );
  }

  Widget _buildContent(List<SavedSearch> searches) {
    final config = ref.watchConfigSearch;

    return PostScope(
      fetcher: (page) => ref
          .read(danbooruPostRepoProvider(config))
          .getPosts(_selectedSearch.toQuery(), page),
      builder: (context, controller) => PostGrid(
        controller: controller,
        itemBuilder:
            (context, index, multiSelectController, scrollController) =>
                DefaultDanbooruImageGridItem(
          index: index,
          multiSelectController: multiSelectController,
          autoScrollController: scrollController,
          controller: controller,
        ),
        sliverHeaders: [
          SliverAppBar(
            title: const Text('saved_search.saved_search_feed').tr(),
            floating: true,
            actions: [
              IconButton(
                onPressed: () => goToSavedSearchEditPage(context),
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
              (t) => t.length < 4 ? 12 : 4,
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
              (t) => t.replaceAll('_', ' '),
            ),
            overflow: TextOverflow.fade,
          ),
        ),
      ),
    );
  }
}

class SavedSearchContextMenu extends ConsumerWidget
    with TagContextMenuButtonConfigMixin {
  const SavedSearchContextMenu({
    super.key,
    required this.search,
    required this.child,
  });

  final SavedSearch search;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tag = search.toQuery();

    return ContextMenuRegion(
      contextMenu: GenericContextMenu(
        buttonConfigs: [
          copyButton(context, tag),
          searchButton(context, tag),
          ContextMenuButtonConfig(
            'download.bulk_download'.tr(),
            onPressed: () {
              goToBulkDownloadPage(context, [tag], ref: ref);
            },
          )
        ],
      ),
      child: child,
    );
  }
}
