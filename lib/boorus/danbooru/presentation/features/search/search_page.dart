// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' hide LoadStatus;
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/search/search.dart';
import 'package:boorusama/boorus/danbooru/application/search_history/search_history.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/application/theme/theme.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/searches.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/related_tag.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/configs/i_config.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/home/home_post_grid.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/search/search_options.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/presentation/widgets/conditional_parent_widget.dart';
import 'package:boorusama/core/presentation/widgets/conditional_render_widget.dart';
import 'related_tag_header.dart';

double? _screenSizeToWidthWeight(ScreenSize size) {
  if (size == ScreenSize.small) return null;
  if (size == ScreenSize.medium) return 0.35;
  if (size == ScreenSize.large) return 0.3;
  return 0.25;
}

class SearchPage extends StatefulWidget {
  const SearchPage({
    Key? key,
    this.initialQuery = '',
    required this.metatags,
    required this.metatagHighlightColor,
  }) : super(key: key);

  final String initialQuery;
  final List<String> metatags;
  final Color metatagHighlightColor;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final _tags = widget.metatags.join('|');
  late final queryEditingController = RichTextController(
    patternMatchMap: {
      RegExp('($_tags)+:'): TextStyle(
        fontWeight: FontWeight.w800,
        color: widget.metatagHighlightColor,
      ),
    },
    onMatch: (List<String> match) {},
  );

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
          listener: (context, state) {
            context.read<SearchBloc>().add(const SearchSuggestionReceived());
          },
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
              final tags =
                  state.selectedTags.map((e) => e.toString()).join(' ');

              context.read<PostBloc>().add(PostRefreshed(tag: tags));
              context
                  .read<RelatedTagBloc>()
                  .add(RelatedTagRequested(query: tags));
            }),
      ],
      child: ConditionalParentWidget(
        condition: Screen.of(context).size != ScreenSize.small,
        conditionalBuilder: (child) => Row(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width *
                      _screenSizeToWidthWeight(Screen.of(context).size)!),
              child: child,
            ),
            const VerticalDivider(),
            Expanded(
              child: BlocBuilder<TagSearchBloc, TagSearchState>(
                builder: (context, tagSearchState) {
                  return Scaffold(
                    body: Column(
                      children: [
                        _buildSearchBodyLargeRightColumn(tagSearchState),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: BlocBuilder<TagSearchBloc, TagSearchState>(
            builder: (context, tagSearchState) =>
                BlocBuilder<SearchBloc, SearchState>(
              builder: (context, searchState) {
                return Scaffold(
                  resizeToAvoidBottomInset: false,
                  floatingActionButton: _shouldShowSearchButton(
                    searchState.displayState,
                    tagSearchState,
                    Screen.of(context).size,
                  )
                      ? _buildSearchButton()
                      : const SizedBox.shrink(),
                  appBar: AppBar(
                    toolbarHeight: kToolbarHeight * 1.2,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    automaticallyImplyLeading: false,
                    title: _buildSearchBar(),
                  ),
                  body: SafeArea(
                    child: MultiBlocListener(
                      listeners: [
                        BlocListener<PostBloc, PostState>(
                            listenWhen: (previous, current) =>
                                current.status == LoadStatus.success &&
                                current.posts.isEmpty &&
                                previous.posts.isEmpty &&
                                searchState.displayState == DisplayState.result,
                            listener: (context, state) {
                              context
                                  .read<SearchBloc>()
                                  .add(const SearchNoData());
                            }),
                        BlocListener<PostBloc, PostState>(
                            listenWhen: (previous, current) =>
                                current.status == LoadStatus.failure &&
                                searchState.displayState == DisplayState.result,
                            listener: (context, state) {
                              context
                                  .read<SearchBloc>()
                                  .add(const SearchError());
                            }),
                        BlocListener<PostBloc, PostState>(
                          listenWhen: (previous, current) =>
                              current.status == LoadStatus.failure &&
                              searchState.displayState == DisplayState.result,
                          listener: (context, state) => showSimpleSnackBar(
                            context: context,
                            duration: const Duration(seconds: 6),
                            content: Text(
                              state.exceptionMessage!,
                            ).tr(),
                          ),
                        ),
                      ],
                      child: BlocBuilder<TagSearchBloc, TagSearchState>(
                        builder: (context, tagSearchState) {
                          return Column(
                            children: [
                              if (tagSearchState.selectedTags.isNotEmpty)
                                ..._buildSelectedTags(tagSearchState),
                              if (Screen.of(context).size ==
                                  ScreenSize.small) ...[
                                _buildSearchBody(tagSearchState)
                              ] else
                                _buildSearchBodyLargeLeftColumn(tagSearchState),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSelectedTags(TagSearchState tagSearchState) {
    return [
      Container(
        margin: const EdgeInsets.only(left: 8),
        height: 35,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: tagSearchState.selectedTags.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildSelectedTagChip(tagSearchState.selectedTags[index]),
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
    ];
  }

  Widget _buildSearchBar() {
    return BlocBuilder<TagSearchBloc, TagSearchState>(
      builder: (context, state) => SearchBar(
        autofocus: _enableAutofocusOnSearchbar(),
        queryEditingController: queryEditingController,
        leading: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            return IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => state.displayState != DisplayState.options
                  ? context
                      .read<SearchBloc>()
                      .add(const SearchGoBackToSearchOptionsRequested())
                  : AppRouter.router.pop(context),
            );
          },
        ),
        trailing: state.query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () =>
                    context.read<TagSearchBloc>().add(const TagSearchCleared()),
              )
            : null,
        onChanged: (value) =>
            context.read<TagSearchBloc>().add(TagSearchChanged(value)),
        onSubmitted: (value) =>
            context.read<TagSearchBloc>().add(const TagSearchSubmitted()),
      ),
    );
  }

  Widget _buildSearchBodyLargeLeftColumn(TagSearchState tagSearchState) {
    return Expanded(
      child: BlocSelector<SearchBloc, SearchState, DisplayState>(
        selector: (state) => state.displayState,
        builder: (context, displayState) {
          if (displayState == DisplayState.suggestion) {
            return TagSuggestionItems(
              tags: tagSearchState.suggestionTags,
              onItemTap: (tag) {
                FocusManager.instance.primaryFocus?.unfocus();
                context.read<TagSearchBloc>().add(TagSearchNewTagSelected(tag));
              },
            );
          } else {
            return SearchOptions(
              config: context.read<IConfig>(),
              onOptionTap: (value) {
                context.read<TagSearchBloc>().add(TagSearchChanged(value));
                queryEditingController.text = '$value:';
              },
              onHistoryTap: (value) {
                FocusManager.instance.primaryFocus?.unfocus();
                context
                    .read<TagSearchBloc>()
                    .add(TagSearchTagFromHistorySelected(value));
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildSearchBodyLargeRightColumn(TagSearchState tagSearchState) {
    return Expanded(
      child: BlocSelector<SearchBloc, SearchState, DisplayState>(
        selector: (state) => state.displayState,
        builder: (context, displayState) {
          if (displayState == DisplayState.result) {
            return ResultView(selectedTags: tagSearchState.selectedTags);
          } else {
            return const Center(
              child: Text('Your result will appear here'),
            );
          }
        },
      ),
    );
  }

  Widget _buildSearchBody(TagSearchState tagSearchState) {
    return Expanded(
      child: BlocSelector<SearchBloc, SearchState, DisplayState>(
        selector: (state) => state.displayState,
        builder: (context, displayState) {
          if (displayState == DisplayState.suggestion) {
            return TagSuggestionItems(
              tags: tagSearchState.suggestionTags,
              onItemTap: (tag) {
                FocusManager.instance.primaryFocus?.unfocus();
                context.read<TagSearchBloc>().add(TagSearchNewTagSelected(tag));
              },
            );
          } else if (displayState == DisplayState.result) {
            return ResultView(selectedTags: tagSearchState.selectedTags);
          } else if (displayState == DisplayState.error) {
            return ErrorResult(text: 'search.errors.generic'.tr());
          } else if (displayState == DisplayState.loadingResult) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (displayState == DisplayState.noResult) {
            return EmptyResult(text: 'search.no_result'.tr());
          } else {
            return SearchOptions(
              config: context.read<IConfig>(),
              onOptionTap: (value) {
                context.read<TagSearchBloc>().add(TagSearchChanged(value));
                queryEditingController.text = '$value:';
              },
              onHistoryTap: (value) {
                FocusManager.instance.primaryFocus?.unfocus();
                context
                    .read<TagSearchBloc>()
                    .add(TagSearchTagFromHistorySelected(value));
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildSearchButton() {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, ss) {
        return BlocListener<SearchHistoryCubit,
            AsyncLoadState<List<SearchHistory>>>(
          listenWhen: (previous, current) =>
              current.status == LoadStatus.success,
          listener: (context, state) {
            context
                .read<SettingsCubit>()
                .update(ss.settings.copyWith(searchHistories: state.data!));
          },
          child: BlocBuilder<TagSearchBloc, TagSearchState>(
            builder: (context, state) {
              return FloatingActionButton(
                onPressed: () {
                  final tags =
                      state.selectedTags.map((e) => e.toString()).join(' ');
                  context.read<SearchBloc>().add(const SearchRequested());
                  context.read<PostBloc>().add(PostRefreshed(tag: tags));
                  context.read<SearchHistoryCubit>().addHistory(tags);
                },
                heroTag: null,
                child: const Icon(Icons.search),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSelectedTagChip(TagSearchItem tagSearchItem) {
    final hasOperator = tagSearchItem.operator != FilterOperator.none;
    final hasMeta = tagSearchItem.metatag != null;
    final hasAny = hasMeta || hasOperator;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasOperator)
          Chip(
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            backgroundColor: Colors.purple,
            labelPadding: const EdgeInsets.symmetric(horizontal: 1),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8))),
            label: Text(
              filterOperatorToStringCharacter(tagSearchItem.operator),
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        if (hasMeta)
          Chip(
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            labelPadding: const EdgeInsets.symmetric(horizontal: 1),
            shape: _getOutlineBorderForMetaChip(hasOperator),
            label: Text(
              tagSearchItem.metatag!,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        Chip(
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          backgroundColor: Colors.grey[800],
          shape: hasAny
              ? const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8)))
              : null,
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
              tagSearchItem.tag,
              overflow: TextOverflow.fade,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        )
      ],
    );
  }

  OutlinedBorder? _getOutlineBorderForMetaChip(bool hasOperator) {
    if (!hasOperator) {
      return const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(8),
        bottomLeft: Radius.circular(8),
      ));
    } else {
      return const RoundedRectangleBorder();
    }
  }

  bool _enableAutofocusOnSearchbar() => widget.initialQuery.isEmpty;
}

bool _shouldShowSearchButton(
  DisplayState displayState,
  TagSearchState tagSearchState,
  ScreenSize size,
) {
  // if (size != ScreenSize.small) return false;

  if (displayState == DisplayState.options) {
    if (tagSearchState.selectedTags.isEmpty) {
      return false;
    } else {
      return true;
    }
  }
  if (displayState == DisplayState.suggestion) return false;
  return false;
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
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Lottie.asset(
                'assets/animations/search-file.json',
                fit: BoxFit.scaleDown,
              ),
            ),
            Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Lottie.asset(
                'assets/animations/server-error.json',
                fit: BoxFit.scaleDown,
              ),
            ),
            Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ResultView extends StatefulWidget {
  const ResultView({
    Key? key,
    required this.selectedTags,
  }) : super(key: key);

  final List<TagSearchItem> selectedTags;

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  final refreshController = RefreshController();

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
      buildWhen: (previous, current) => !current.hasMore,
      builder: (context, state) {
        return InfiniteLoadList(
          refreshController: refreshController,
          enableLoadMore: state.hasMore,
          onLoadMore: () => context.read<PostBloc>().add(PostFetched(
                tags: widget.selectedTags.map((e) => e.toString()).join(' '),
              )),
          onRefresh: (controller) {
            context.read<PostBloc>().add(PostRefreshed(
                tag: widget.selectedTags.map((e) => e.toString()).join(' ')));
            Future.delayed(const Duration(milliseconds: 500),
                () => controller.refreshCompleted());
          },
          builder: (context, controller) => CustomScrollView(
            controller: controller,
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).viewPadding.top,
                ),
              ),
              SliverToBoxAdapter(
                child: BlocBuilder<RelatedTagBloc, AsyncLoadState<RelatedTag>>(
                  builder: (context, state) {
                    if (state.status == LoadStatus.success) {
                      return BlocSelector<ThemeBloc, ThemeState, ThemeMode>(
                        selector: (state) => state.theme,
                        builder: (context, theme) {
                          return _RelatedTag(
                            relatedTag: state.data!,
                            theme: theme,
                          );
                        },
                      );
                    } else if (state.status == LoadStatus.failure) {
                      return const SizedBox.shrink();
                    } else {
                      return const TagChipsPlaceholder();
                    }
                  },
                ),
              ),
              HomePostGrid(
                controller: controller,
                onTap: () => FocusScope.of(context).unfocus(),
              ),
              BlocBuilder<PostBloc, PostState>(
                builder: (context, state) {
                  if (state.status == LoadStatus.loading) {
                    return const SliverPadding(
                      padding: EdgeInsets.only(bottom: 20, top: 20),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: CircularProgressIndicator(),
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
    );
  }
}

class _RelatedTag extends StatelessWidget {
  const _RelatedTag({
    Key? key,
    required this.relatedTag,
    required this.theme,
  }) : super(key: key);

  final RelatedTag relatedTag;
  final ThemeMode theme;

  @override
  Widget build(BuildContext context) {
    return ConditionalRenderWidget(
      condition: relatedTag.tags.isNotEmpty,
      childBuilder: (context) => RelatedTagHeader(
        relatedTag: relatedTag,
        theme: theme,
      ),
    );
  }
}
