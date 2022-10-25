// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rich_text_controller/rich_text_controller.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/search/search.dart';
import 'package:boorusama/boorus/danbooru/application/search_history/search_history.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/features/search/search_options.dart';
import 'package:boorusama/boorus/danbooru/ui/features/search/selected_tag_chip.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/tags/metatag.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import 'package:boorusama/core/ui/search_bar.dart';
import 'empty_view.dart';
import 'error_view.dart';
import 'result_view.dart';
import 'search_button.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    this.initialQuery = '',
    required this.metatags,
    required this.metatagHighlightColor,
  });

  final String initialQuery;
  final List<Metatag> metatags;
  final Color metatagHighlightColor;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final _tags = widget.metatags.map((e) => e.name).join('|');
  late final queryEditingController = RichTextController(
    patternMatchMap: {
      RegExp('($_tags)+:'): TextStyle(
        fontWeight: FontWeight.w800,
        color: widget.metatagHighlightColor,
      ),
    },
    // ignore: no-empty-block
    onMatch: (List<String> match) {},
  );
  final compositeSubscription = CompositeSubscription();
  final FocusNode focus = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context
            .read<TagSearchBloc>()
            .add(TagSearchNewRawStringTagSelected(widget.initialQuery));
        context.read<SearchBloc>().add(const SearchRequested());
        context.read<PostBloc>().add(PostRefreshed(
              tag: widget.initialQuery,
              fetcher: SearchedPostFetcher.fromTags(widget.initialQuery),
            ));
      });
    } else {
      Future.delayed(const Duration(milliseconds: 100), () {
        focus.requestFocus();
      });
    }

    context.read<SearchHistoryCubit>().getSearchHistory();

    queryEditingController.addListener(() {
      queryEditingController.selection = TextSelection.fromPosition(
        TextPosition(offset: queryEditingController.text.length),
      );
    });

    Rx.combineLatest2<SearchState, PostState, Tuple2<SearchState, PostState>>(
      context.read<SearchBloc>().stream,
      context.read<PostBloc>().stream,
      Tuple2.new,
    )
        .where((event) =>
            event.item2.status == LoadStatus.failure &&
            event.item1.displayState == DisplayState.result)
        .listen((state) {
      context.read<SearchBloc>().add(const SearchError());
      showSimpleSnackBar(
        context: context,
        duration: const Duration(seconds: 6),
        content: Text(
          state.item2.exceptionMessage!,
        ).tr(),
      );
    }).addTo(compositeSubscription);

    Rx.combineLatest2<SearchState, PostState, Tuple2<SearchState, PostState>>(
      context.read<SearchBloc>().stream,
      context.read<PostBloc>().stream,
      Tuple2.new,
    )
        .where((event) =>
            event.item2.status == LoadStatus.success &&
            event.item2.posts.isEmpty &&
            event.item1.displayState == DisplayState.result)
        .listen((state) {
      context.read<SearchBloc>().add(const SearchNoData());
    }).addTo(compositeSubscription);
  }

  @override
  void dispose() {
    compositeSubscription.dispose();
    queryEditingController.dispose();
    focus.dispose();
    super.dispose();
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
            final tags = state.selectedTags.map((e) => e.toString()).join(' ');

            context.read<PostBloc>().add(PostRefreshed(
                  tag: tags,
                  fetcher: SearchedPostFetcher.fromTags(tags),
                ));
            context
                .read<RelatedTagBloc>()
                .add(RelatedTagRequested(query: tags));
          },
        ),
      ],
      child: Screen.of(context).size != ScreenSize.small
          ? _LargeLayout(
              focus: focus,
              queryEditingController: queryEditingController,
            )
          : _SmallLayout(
              focus: focus,
              queryEditingController: queryEditingController,
            ),
    );
  }
}

class _LargeLayout extends StatelessWidget {
  const _LargeLayout({
    required this.focus,
    required this.queryEditingController,
  });

  final FocusNode focus;
  final RichTextController queryEditingController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const SearchButton(),
      body: Row(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 250),
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: _AppBar(
                focus: focus,
                queryEditingController: queryEditingController,
              ),
              body: Column(
                children: [
                  const _TagRow(),
                  const _Divider(),
                  Expanded(
                    child: BlocSelector<SearchBloc, SearchState, DisplayState>(
                      selector: (state) => state.displayState,
                      builder: (context, displayState) {
                        return displayState == DisplayState.suggestion
                            ? _TagSuggestionItems(
                                queryEditingController: queryEditingController,
                              )
                            : SearchOptions(
                                metatags: context.read<TagInfo>().metatags,
                                onOptionTap: (value) {
                                  final query = '$value:';
                                  queryEditingController.text = query;
                                  context
                                      .read<TagSearchBloc>()
                                      .add(TagSearchChanged(query));
                                },
                                onHistoryTap: (value) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  context.read<TagSearchBloc>().add(
                                        TagSearchTagFromHistorySelected(value),
                                      );
                                },
                                onTagTap: (value) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  context.read<TagSearchBloc>().add(
                                        TagSearchNewRawStringTagSelected(value),
                                      );
                                },
                              );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(),
          Expanded(
            child: BlocSelector<SearchBloc, SearchState, DisplayState>(
              selector: (state) => state.displayState,
              builder: (context, displayState) {
                if (displayState == DisplayState.result) {
                  return const ResultView();
                } else if (displayState == DisplayState.error) {
                  return ErrorView(text: 'search.errors.generic'.tr());
                } else if (displayState == DisplayState.loadingResult) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (displayState == DisplayState.noResult) {
                  return EmptyView(text: 'search.no_result'.tr());
                } else {
                  return const Center(
                    child: Text('Your result will appear here'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: prefer_mixin
class _AppBar extends StatelessWidget with PreferredSizeWidget {
  const _AppBar({
    required this.focus,
    required this.queryEditingController,
  });

  final FocusNode focus;
  final RichTextController queryEditingController;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: _SearchBar(
        focus: focus,
        queryEditingController: queryEditingController,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 1.2);
}

class _SmallLayout extends StatelessWidget {
  const _SmallLayout({
    required this.focus,
    required this.queryEditingController,
  });

  final FocusNode focus;
  final RichTextController queryEditingController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: const SearchButton(),
      appBar: _AppBar(
        focus: focus,
        queryEditingController: queryEditingController,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const _TagRow(),
            const _Divider(),
            Expanded(
              child: BlocSelector<SearchBloc, SearchState, DisplayState>(
                selector: (state) => state.displayState,
                builder: (context, displayState) {
                  if (displayState == DisplayState.suggestion) {
                    return _TagSuggestionItems(
                      queryEditingController: queryEditingController,
                    );
                  } else if (displayState == DisplayState.result) {
                    return const ResultView();
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
                      metatags: context.read<TagInfo>().metatags,
                      onOptionTap: (value) {
                        final query = '$value:';
                        queryEditingController.text = query;
                        context
                            .read<TagSearchBloc>()
                            .add(TagSearchChanged(query));
                      },
                      onHistoryTap: (value) {
                        FocusManager.instance.primaryFocus?.unfocus();
                        context
                            .read<TagSearchBloc>()
                            .add(TagSearchTagFromHistorySelected(value));
                      },
                      onTagTap: (value) {
                        FocusManager.instance.primaryFocus?.unfocus();
                        context
                            .read<TagSearchBloc>()
                            .add(TagSearchNewRawStringTagSelected(value));
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagRow extends StatelessWidget {
  const _TagRow();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TagSearchBloc, TagSearchState, List<TagSearchItem>>(
      selector: (state) => state.selectedTags,
      builder: (context, tags) {
        // final bloc = context.read<TagSearchBloc>();

        return tags.isNotEmpty
            ? Row(children: [
                const SizedBox(width: 10),
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => showCupertinoModalBottomSheet(
                    context: context,
                    builder: (context) => ModalSelectedTag(
                      onBulkDownload: () {
                        AppRouter.router.navigateTo(
                          context,
                          '/bulk_download',
                          routeSettings: RouteSettings(
                            arguments: [
                              tags.map((e) => e.toString()).toList(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  child: const Icon(Icons.more_vert),
                ),
                Expanded(child: _SelectedTagChips(tags: tags)),
              ])
            : const SizedBox.shrink();
      },
    );
  }
}

class _TagSuggestionItems extends StatelessWidget {
  const _TagSuggestionItems({
    required this.queryEditingController,
  });

  final TextEditingController queryEditingController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TagSearchBloc, TagSearchState>(
      builder: (context, tagState) {
        return BlocBuilder<SearchHistorySuggestionsBloc,
            SearchHistorySuggestionsState>(
          builder: (context, state) {
            return SliverTagSuggestionItemsWithHistory(
              tags: tagState.suggestionTags,
              histories: state.histories,
              currentQuery: tagState.query,
              onHistoryTap: (history) {
                FocusManager.instance.primaryFocus?.unfocus();
                context
                    .read<TagSearchBloc>()
                    .add(TagSearchTagFromHistorySelected(history.tag));
              },
              onItemTap: (tag) {
                FocusManager.instance.primaryFocus?.unfocus();
                context.read<TagSearchBloc>().add(TagSearchNewTagSelected(tag));
              },
            );
          },
        );
      },
    );
  }
}

// ignore: prefer-single-widget-per-file
class ModalSelectedTag extends StatelessWidget {
  const ModalSelectedTag({
    super.key,
    this.onClear,
    this.onBulkDownload,
  });

  final void Function()? onClear;
  final void Function()? onBulkDownload;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ListTile(
            //   title: const Text('Clear'),
            //   leading: const Icon(Icons.clear_all),
            //   onTap: () {
            //     Navigator.of(context).pop();
            //     onClear?.call();
            //   },
            // ),
            ListTile(
              title: const Text('Bulk download'),
              leading: const Icon(Icons.download),
              onTap: () {
                Navigator.of(context).pop();
                onBulkDownload?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TagSearchBloc, TagSearchState, List<TagSearchItem>>(
      selector: (state) => state.selectedTags,
      builder: (context, tags) => tags.isNotEmpty
          ? const Divider(
              height: 15,
              thickness: 1,
            )
          : const SizedBox.shrink(),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.focus,
    required this.queryEditingController,
  });

  final FocusNode focus;
  final RichTextController queryEditingController;

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      focus: focus,
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
      trailing: BlocBuilder<TagSearchBloc, TagSearchState>(
        builder: (context, state) => state.query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () =>
                    context.read<TagSearchBloc>().add(const TagSearchCleared()),
              )
            : const SizedBox.shrink(),
      ),
      onChanged: (value) {
        context.read<TagSearchBloc>().add(TagSearchChanged(value));
        context
            .read<SearchHistorySuggestionsBloc>()
            .add(SearchHistorySuggestionsFetched(text: value));
      },
      onSubmitted: (value) =>
          context.read<TagSearchBloc>().add(const TagSearchSubmitted()),
    );
  }
}

class _SelectedTagChips extends StatelessWidget {
  const _SelectedTagChips({
    required this.tags,
  });

  final List<TagSearchItem> tags;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      height: 35,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SelectedTagChip(
              tagSearchItem: tags[index],
            ),
          );
        },
      ),
    );
  }
}
