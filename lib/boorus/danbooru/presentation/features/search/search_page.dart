// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/search/search.dart';
import 'package:boorusama/boorus/danbooru/application/search_history/search_history.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/searches.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/configs/i_config.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/search/search_options.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/search/selected_tag_chips.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/presentation/widgets/conditional_parent_widget.dart';
import 'empty_view.dart';
import 'error_view.dart';
import 'result_view.dart';

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
        conditionalBuilder: (child) => Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Row(
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
                    ? const _SearchButton()
                    : const SizedBox.shrink(),
                appBar: AppBar(
                  toolbarHeight: kToolbarHeight * 1.2,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  automaticallyImplyLeading: false,
                  title: _SearchBar(
                    autoFocus: widget.initialQuery.isEmpty,
                    queryEditingController: queryEditingController,
                  ),
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
                            context.read<SearchBloc>().add(const SearchError());
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
    );
  }

  List<Widget> _buildSelectedTags(TagSearchState tagSearchState) {
    return [
      _SelectedTagChips(
        selectedTags: tagSearchState.selectedTags,
      ),
      const Divider(
        height: 15,
        thickness: 3,
        indent: 10,
        endIndent: 10,
      ),
    ];
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
            return ErrorView(text: 'search.errors.generic'.tr());
          } else if (displayState == DisplayState.loadingResult) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (displayState == DisplayState.noResult) {
            return EmptyView(text: 'search.no_result'.tr());
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
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    Key? key,
    required this.autoFocus,
    required this.queryEditingController,
  }) : super(key: key);

  final bool autoFocus;
  final RichTextController queryEditingController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TagSearchBloc, TagSearchState>(
      builder: (context, state) => SearchBar(
        autofocus: autoFocus,
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
}

class _SelectedTagChips extends StatelessWidget {
  const _SelectedTagChips({
    Key? key,
    required this.selectedTags,
  }) : super(key: key);

  final List<TagSearchItem> selectedTags;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      height: 35,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: selectedTags.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SelectedTagChip(
              tagSearchItem: selectedTags[index],
            ),
          );
        },
      ),
    );
  }
}

class _SearchButton extends StatelessWidget {
  const _SearchButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
