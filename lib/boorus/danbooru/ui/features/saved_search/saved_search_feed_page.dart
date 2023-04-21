// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/application/saved_searches.dart';
import 'package:boorusama/boorus/danbooru/domain/saved_searches.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/tag_chips_placeholder.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/generic_no_data_box.dart';
import 'package:boorusama/main.dart';

class SavedSearchFeedPage extends StatefulWidget {
  const SavedSearchFeedPage({
    super.key,
  });

  @override
  State<SavedSearchFeedPage> createState() => _SavedSearchFeedPageState();
}

class _SavedSearchFeedPageState extends State<SavedSearchFeedPage>
    with DanbooruPostCubitMixin {
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
    final savedSearchState =
        context.select((SavedSearchFeedBloc bloc) => bloc.state);

    return savedSearchState.savedSearches.isEmpty
        ? _buildLandingView(context)
        : _buildListView(context, savedSearchState);
  }

  Widget _buildListView(
    BuildContext context,
    SavedSearchFeedState savedSearchState,
  ) {
    return BlocListener<SavedSearchFeedBloc, SavedSearchFeedState>(
      listenWhen: (previous, current) =>
          previous.selectedSearch != current.selectedSearch,
      listener: (context, state) {
        _sendRefresh(state.selectedSearch);
      },
      child: BlocBuilder<DanbooruPostCubit, DanbooruPostState>(
        builder: (context, state) {
          return DanbooruInfinitePostList(
            refreshing: state.refreshing,
            loading: state.loading,
            hasMore: state.hasMore,
            error: state.error,
            data: state.data,
            onRefresh: () {
              _sendRefresh(savedSearchState.selectedSearch);
            },
            onLoadMore: () {
              fetch();
            },
            sliverHeaderBuilder: (context) => [
              SliverAppBar(
                title: const Text('saved_search.saved_search_feed').tr(),
                floating: true,
                elevation: 0,
                shadowColor: Colors.transparent,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  child: _buildTags(
                    savedSearchState.savedSearches,
                    savedSearchState.selectedSearch,
                    savedSearchState.status,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLandingView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('saved_search.saved_search_feed').tr(),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 48,
                horizontal: 8,
              ),
              child: Column(
                children: [
                  GenericNoDataBox(
                    text: 'saved_search.empty_saved_search'.tr(),
                  ),
                  TextButton(
                    onPressed: () => launchExternalUrl(
                      Uri.parse(savedSearchHelpUrl),
                    ),
                    child: const Text('saved_search.saved_search_help').tr(),
                  ),
                  ElevatedButton(
                    onPressed: () => _onAddSearch(context),
                    child: const Text('generic.action.add').tr(),
                  ),
                ],
              ),
            ),
            const Divider(
              thickness: 2,
            ),
            ListTile(
              title: const Text('saved_search.saved_search_examples').tr(),
            ),
            _ExampleContainer(
              title: 'Follow artists',
              query: 'artistA or artistB or artistC or artistD',
              explain: 'Follow posts from artistA, artistB, artistC, artistD.',
              onTry: (query) => _onAddSearch(context, query: query),
            ),
            _ExampleContainer(
              title: 'Follow specific characters from an artist',
              query: 'artistA (characterA or characterB or characterC)',
              explain:
                  'Follow posts that feature characterA or characterB or characterC from artistA.',
              onTry: (query) => _onAddSearch(context, query: query),
            ),
            _ExampleContainer(
              title: 'Follow a specific thing',
              query:
                  'artistA ((characterA 1girl -ocean) or (characterB swimsuit))',
              explain:
                  'Follow posts that feature characterA with 1girl tag but without the ocean tag or characterB with swimsuit tag from artistA.',
              onTry: (query) => _onAddSearch(context, query: query),
            ),
            _ExampleContainer(
              title: 'Follow random tags',
              query: 'artistA or characterB or scenery',
              explain:
                  'Follow posts that include artistA or characterB or scenery.',
              onTry: (query) => _onAddSearch(context, query: query),
            ),
          ],
        ),
      ),
    );
  }

  void _onAddSearch(
    BuildContext context, {
    String? query,
  }) {
    goToSavedSearchCreatePage(
      context,
      initialValue: SavedSearch.empty().copyWith(query: query),
    );
  }

  Widget _buildTags(
    List<SavedSearch> searches,
    SavedSearch selectedSearch,
    SavedSearchFeedStatus status,
  ) {
    switch (status) {
      case SavedSearchFeedStatus.initial:
        return const TagChipsPlaceholder();
      case SavedSearchFeedStatus.noData:
      case SavedSearchFeedStatus.failure:
        return const SizedBox.shrink();
      case SavedSearchFeedStatus.loaded:
        return ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: searches.length,
          itemBuilder: (context, index) {
            final isSelected = selectedSearch == searches[index];

            final text =
                searches[index].labels.first.removeUnderscoreWithSpace();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                disabledColor: Theme.of(context).chipTheme.disabledColor,
                backgroundColor: Theme.of(context).chipTheme.backgroundColor,
                selectedColor: Theme.of(context).chipTheme.selectedColor,
                selected: isSelected,
                onSelected: (selected) {
                  if (!isSelected) {
                    _selectedSearchStream.value = searches[index];
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

  void _sendRefresh(SavedSearch search) => refresh();
}

class _ExampleContainer extends StatelessWidget {
  const _ExampleContainer({
    required this.title,
    required this.query,
    required this.explain,
    required this.onTry,
  });

  final String title;
  final String query;
  final String explain;
  final void Function(String query) onTry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Card(
                margin: const EdgeInsets.all(8),
                color: Theme.of(context).colorScheme.background,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Text(query),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(explain),
              ),
              Row(
                children: [
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => onTry(query),
                    child: const Text('saved_search.saved_search_try').tr(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
