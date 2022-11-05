// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/fetchers/saved_search_post_fetcher.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/saved_search/saved_search_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/saved_search/saved_search_feed_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/saved_searches/saved_searches.dart';
import 'package:boorusama/boorus/danbooru/ui/features/home/home_post_grid.dart';
import 'package:boorusama/boorus/danbooru/ui/features/saved_search/saved_search_page.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/tag_chips_placeholder.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/infinite_load_list.dart';

class SavedSearchFeedPage extends StatefulWidget {
  const SavedSearchFeedPage({
    super.key,
  });

  @override
  State<SavedSearchFeedPage> createState() => _SavedSearchFeedPageState();
}

class _SavedSearchFeedPageState extends State<SavedSearchFeedPage> {
  final _selectedSearchStream = BehaviorSubject<SavedSearch>();
  final _compositeSubscription = CompositeSubscription();

  @override
  void initState() {
    super.initState();

    _selectedSearchStream
        .debounceTime(const Duration(milliseconds: 150))
        .distinct()
        .listen((value) => context
            .read<SavedSearchFeedBloc>()
            .add(SavedSearchFeedSelectedTagChanged(savedSearch: value)))
        .addTo(_compositeSubscription);
  }

  @override
  void dispose() {
    _compositeSubscription.dispose();
    _selectedSearchStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SavedSearchFeedBloc, SavedSearchFeedState>(
      listenWhen: (previous, current) =>
          previous.selectedSearch != current.selectedSearch,
      listener: (context, state) {
        _sendRefresh(state.selectedSearch);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Following'),
          actions: [
            IconButton(
              onPressed: () => showMaterialModalBottomSheet(
                context: context,
                builder: (context) => BlocProvider.value(
                  value: context.read<SavedSearchBloc>(),
                  child: const SavedSearchPage(),
                ),
              ),
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        body: BlocBuilder<SavedSearchFeedBloc, SavedSearchFeedState>(
          builder: (context, savedSearchState) {
            return BlocBuilder<PostBloc, PostState>(
              builder: (context, state) {
                return InfiniteLoadListScrollView(
                  enableLoadMore: state.hasMore,
                  onRefresh: (controller) {
                    _sendRefresh(savedSearchState.selectedSearch);
                    Future.delayed(
                      const Duration(seconds: 1),
                      () => controller.refreshCompleted(),
                    );
                  },
                  onLoadMore: () {
                    context.read<PostBloc>().add(PostFetched(
                          tags: savedSearchState.selectedSearch.toQuery(),
                          fetcher: SavedSearchPostFetcher(
                            savedSearchState.selectedSearch,
                          ),
                        ));
                  },
                  sliverBuilder: (controller) => [
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        height: 50,
                        child: _buildTags(savedSearchState),
                      ),
                    ),
                    HomePostGrid(controller: controller),
                  ],
                  isLoading: state.loading,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTags(SavedSearchFeedState savedSearchState) {
    switch (savedSearchState.status) {
      case SavedSearchFeedStatus.initial:
        return const TagChipsPlaceholder();
      case SavedSearchFeedStatus.noData:
      case SavedSearchFeedStatus.failure:
        return const SizedBox.shrink();
      case SavedSearchFeedStatus.loaded:
        return ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: savedSearchState.savedSearches.length,
          itemBuilder: (context, index) {
            final isSelected = savedSearchState.selectedSearch ==
                savedSearchState.savedSearches[index];

            final text = savedSearchState.savedSearches[index].labels.first
                .removeUnderscoreWithSpace();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                disabledColor: Theme.of(context).chipTheme.disabledColor,
                backgroundColor: Theme.of(context).chipTheme.backgroundColor,
                selectedColor: Theme.of(context).chipTheme.selectedColor,
                selected: isSelected,
                onSelected: (selected) {
                  if (!isSelected) {
                    _selectedSearchStream.value =
                        savedSearchState.savedSearches[index];
                  }
                },
                padding: EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: text.length < 4 ? 12 : 4,
                ),
                labelPadding: const EdgeInsets.all(1),
                visualDensity: VisualDensity.compact,
                side: BorderSide(
                  width: 0.5,
                  color: Theme.of(context).hintColor,
                ),
                label: Text(
                  text,
                  overflow: TextOverflow.fade,
                ),
              ),
            );
          },
        );
    }
  }

  void _sendRefresh(SavedSearch search) =>
      context.read<PostBloc>().add(PostRefreshed(
            tag: search.toQuery(),
            fetcher: SavedSearchPostFetcher(search),
          ));
}
