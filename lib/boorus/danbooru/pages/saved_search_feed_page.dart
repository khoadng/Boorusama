// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/saved_searches/saved_searches.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/string.dart';
import 'widgets/saved_searches/saved_search_landing_view.dart';

class SavedSearchFeedPage extends ConsumerStatefulWidget {
  const SavedSearchFeedPage({
    super.key,
  });

  static Widget of(BuildContext context) {
    return const CustomContextMenuOverlay(
      child: SavedSearchFeedPage(),
    );
  }

  @override
  ConsumerState<SavedSearchFeedPage> createState() =>
      _SavedSearchFeedPageState();
}

class _SavedSearchFeedPageState extends ConsumerState<SavedSearchFeedPage> {
  var _selectedSearch = SavedSearch.all();

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfig;
    final savedSearcheAsync = ref.watch(danbooruSavedSearchesProvider(config));

    return savedSearcheAsync.when(
      data: (searches) => searches.isNotEmpty
          ? PostScope(
              fetcher: (page) => ref
                  .read(danbooruPostRepoProvider(config))
                  .getPosts(_selectedSearch.toQuery(), page),
              builder: (context, controller, errors) =>
                  DanbooruInfinitePostList(
                errors: errors,
                controller: controller,
                sliverHeaderBuilder: (context) => [
                  SliverAppBar(
                    title: const Text('saved_search.saved_search_feed').tr(),
                    floating: true,
                    actions: [
                      IconButton(
                        onPressed: () => goToSavedSearchEditPage(context),
                        icon: const Icon(Icons.settings),
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
            )
          : const SavedSearchLandingView(),
      error: (error, stackTrace) => const ErrorBox(),
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
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
      itemBuilder: (context, index) {
        final isSelected = selectedSearch == searches[index];

        final text = searches[index].labels.firstOption;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(
            disabledColor: context.theme.chipTheme.disabledColor,
            backgroundColor: context.theme.chipTheme.backgroundColor,
            selectedColor: context.theme.chipTheme.selectedColor,
            selected: isSelected,
            onSelected: (selected) {
              if (!isSelected) {
                onSearchChanged(searches[index]);
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
              color: context.theme.hintColor,
            ),
            label: Text(
              text.fold(
                () => '<empty>',
                (t) => t.replaceUnderscoreWithSpace(),
              ),
              overflow: TextOverflow.fade,
            ),
          ),
        );
      },
    );
  }
}
