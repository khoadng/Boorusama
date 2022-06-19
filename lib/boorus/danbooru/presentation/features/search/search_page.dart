// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' hide LoadStatus;

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/post_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/search/search_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/search_history/search_history_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/tag/filter_operator.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag_search_bloc.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/blacklisted_tags/blacklisted_tags_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/home/latest/home_post_grid.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/search/search_options.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/infinite_load_list.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/search_bar.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import '../../shared/tag_suggestion_items.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    Key? key,
    this.initialQuery = '',
  }) : super(key: key);

  final String initialQuery;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final queryEditingController = TextEditingController();
  final refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context
            .read<TagSearchBloc>()
            .add(TagSearchNewRawStringTagSelected(widget.initialQuery));
        context.read<SearchBloc>().add(const SearchRequested());
        context.read<PostBloc>().add(PostRefreshed(tag: widget.initialQuery));
        FocusScope.of(context).unfocus();
      });
    }

    context.read<SearchHistoryCubit>().getSearchHistory();

    queryEditingController.addListener(() {
      queryEditingController.selection = TextSelection.fromPosition(
          TextPosition(offset: queryEditingController.text.length));
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TagSearchBloc, TagSearchState>(
          listenWhen: (previous, current) => current.query.isEmpty,
          listener: (context, state) {
            context.read<SearchBloc>().add(const SearchQueryEmpty());
            context.read<TagSearchBloc>().add(const TagSearchCleared());
            queryEditingController.clear();
          },
        ),
        BlocListener<TagSearchBloc, TagSearchState>(
          listenWhen: (previous, current) => current.suggestionTags.isNotEmpty,
          listener: (context, state) =>
              context.read<SearchBloc>().add(const SearchSuggestionReceived()),
        ),
        BlocListener<TagSearchBloc, TagSearchState>(
          listenWhen: (previous, current) =>
              current.selectedTags.isEmpty && previous.selectedTags.length == 1,
          listener: (context, state) =>
              context.read<SearchBloc>().add(const SearchSelectedTagCleared()),
        ),
        BlocListener<TagSearchBloc, TagSearchState>(
            listenWhen: (previous, current) =>
                current.selectedTags != previous.selectedTags,
            listener: (context, state) {
              context.read<PostBloc>().add(PostRefreshed(
                  tag: state.selectedTags.map((e) => e.toString()).join(' ')));
            }),
      ],
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, searchState) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              floatingActionButton:
                  searchState.displayState == DisplayState.result
                      ? const SizedBox.shrink()
                      : BlocBuilder<TagSearchBloc, TagSearchState>(
                          builder: (context, state) {
                            return FloatingActionButton(
                              onPressed: () {
                                context
                                    .read<SearchBloc>()
                                    .add(const SearchRequested());
                                context.read<PostBloc>().add(PostRefreshed(
                                    tag: state.selectedTags
                                        .map((e) => e.toString())
                                        .join(' ')));
                                context.read<SearchHistoryCubit>().addHistory(
                                    state.selectedTags
                                        .map((e) => e.toString())
                                        .join(' '));
                              },
                              heroTag: null,
                              child: const Icon(Icons.search),
                            );
                          },
                        ),
              appBar: AppBar(
                toolbarHeight: kToolbarHeight * 1.2,
                elevation: 0,
                shadowColor: Colors.transparent,
                automaticallyImplyLeading: false,
                title: BlocBuilder<TagSearchBloc, TagSearchState>(
                  builder: (context, state) => SearchBar(
                    autofocus: true,
                    queryEditingController: queryEditingController,
                    leading: BlocBuilder<SearchBloc, SearchState>(
                      builder: (context, state) {
                        return IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => state.displayState ==
                                  DisplayState.result
                              ? context.read<SearchBloc>().add(
                                  const SearchGoBackToSearchOptionsRequested())
                              : AppRouter.router.pop(context),
                        );
                      },
                    ),
                    trailing: state.query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => context
                                .read<TagSearchBloc>()
                                .add(const TagSearchCleared()),
                          )
                        : null,
                    onChanged: (value) => context
                        .read<TagSearchBloc>()
                        .add(TagSearchChanged(value)),
                    onSubmitted: (value) => context
                        .read<TagSearchBloc>()
                        .add(const TagSearchSubmitted()),
                  ),
                ),
              ),
              body: SafeArea(
                child: BlocBuilder<TagSearchBloc, TagSearchState>(
                  builder: (context, tagSearchState) {
                    return Column(
                      children: [
                        if (tagSearchState.selectedTags.isNotEmpty) ...[
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            height: 35,
                            child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: tagSearchState.selectedTags.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: _buildSelectedTagChip(
                                      tagSearchState.selectedTags[index]),
                                );
                              },
                            ),
                          ),
                          const Divider(
                            height: 15,
                            thickness: 3,
                            indent: 10,
                            endIndent: 10,
                          ),
                        ],
                        BlocSelector<SearchBloc, SearchState, DisplayState>(
                          selector: (state) => state.displayState,
                          builder: (context, displayState) {
                            if (displayState == DisplayState.suggestion) {
                              return Expanded(
                                child: TagSuggestionItems(
                                  tags: tagSearchState.suggestionTags,
                                  onItemTap: (tag) {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    context
                                        .read<TagSearchBloc>()
                                        .add(TagSearchNewTagSelected(tag));
                                  },
                                ),
                              );
                            } else if (displayState == DisplayState.result) {
                              return Expanded(
                                child: BlocBuilder<PostBloc, PostState>(
                                  buildWhen: (previous, current) =>
                                      !current.hasMore,
                                  builder: (context, state) {
                                    return InfiniteLoadList(
                                      refreshController: refreshController,
                                      enableLoadMore: state.hasMore,
                                      onLoadMore: () => context
                                          .read<PostBloc>()
                                          .add(PostFetched(
                                            tags: tagSearchState.selectedTags
                                                .map((e) => e.toString())
                                                .join(' '),
                                          )),
                                      onRefresh: (controller) {
                                        context.read<PostBloc>().add(
                                            PostRefreshed(
                                                tag: tagSearchState.selectedTags
                                                    .map((e) => e.toString())
                                                    .join(' ')));
                                        Future.delayed(
                                            const Duration(milliseconds: 500),
                                            () =>
                                                controller.refreshCompleted());
                                      },
                                      builder: (context, controller) =>
                                          CustomScrollView(
                                        controller: controller,
                                        slivers: <Widget>[
                                          HomePostGrid(
                                            controller: controller,
                                            onTap: () => FocusScope.of(context)
                                                .unfocus(),
                                          ),
                                          BlocBuilder<PostBloc, PostState>(
                                            builder: (context, state) {
                                              if (state.status ==
                                                  LoadStatus.loading) {
                                                return const SliverPadding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 20, top: 20),
                                                  sliver: SliverToBoxAdapter(
                                                    child: Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return const SliverToBoxAdapter(
                                                  child: SizedBox.shrink(),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            } else if (displayState == DisplayState.error) {
                              return const ErrorResult(
                                  text: 'Something went wrong');
                            } else if (displayState ==
                                DisplayState.loadingResult) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (displayState == DisplayState.noResult) {
                              return const EmptyResult(
                                  text:
                                      'We searched far and wide, but no results were found.');
                            } else {
                              return SearchOptions(
                                onOptionTap: (value) {
                                  context
                                      .read<TagSearchBloc>()
                                      .add(TagSearchChanged(value));
                                  queryEditingController.text = '$value:';
                                },
                                onHistoryTap: (value) {
                                  context.read<TagSearchBloc>().add(
                                      TagSearchTagFromHistorySelected(value));
                                },
                              );
                            }
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSelectedTagChip(TagSearchItem tagSearchItem) {
    if (tagSearchItem.operator == FilterOperator.none) {
      return Chip(
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          backgroundColor: Colors.grey[800],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          deleteIcon: const Icon(
            FontAwesomeIcons.xmark,
            color: Colors.red,
            size: 15,
          ),
          labelPadding: const EdgeInsets.symmetric(horizontal: 2),
          onDeleted: () => context
              .read<TagSearchBloc>()
              .add(TagSearchSelectedTagRemoved(tagSearchItem)),
          label: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.85),
            child: Text(
              tagSearchItem.tag.label,
              overflow: TextOverflow.fade,
            ),
          ));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Chip(
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          labelPadding: const EdgeInsets.symmetric(horizontal: 1),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8), bottomLeft: Radius.circular(8))),
          label: Text(
            filterOperatorToStringCharacter(tagSearchItem.operator),
          ),
        ),
        Chip(
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          backgroundColor: Colors.grey[800],
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8))),
          deleteIcon: const Icon(
            FontAwesomeIcons.xmark,
            color: Colors.red,
            size: 15,
          ),
          onDeleted: () => context
              .read<TagSearchBloc>()
              .add(TagSearchSelectedTagRemoved(tagSearchItem)),
          labelPadding: const EdgeInsets.symmetric(horizontal: 2),
          label: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.85),
            child: Text(
              tagSearchItem.tag.label,
              overflow: TextOverflow.fade,
            ),
          ),
        )
      ],
    );
  }
}

class EmptyResult extends StatelessWidget {
  const EmptyResult({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Lottie.asset(
              'assets/animations/search-file.json',
              fit: BoxFit.scaleDown,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorResult extends StatelessWidget {
  const ErrorResult({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Lottie.asset(
              'assets/animations/server-error.json',
              fit: BoxFit.scaleDown,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
