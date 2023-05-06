// Flutter imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/application/search/search_notifier.dart';
import 'package:boorusama/core/application/search/search_provider.dart';
import 'package:boorusama/core/application/search/selected_tags_notifier.dart';
import 'package:boorusama/core/application/search/suggestions_notifier.dart';
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rich_text_controller/rich_text_controller.dart';
import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/ui/utils.dart';
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/domain/searches.dart';
import 'package:boorusama/core/domain/tags/metatag.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/search/metatags/danbooru_metatags_section.dart';
import 'package:boorusama/core/ui/search/search_landing_view.dart';
import 'package:boorusama/core/ui/search/selected_tag_list.dart';
import 'package:boorusama/core/ui/search_bar.dart';
import 'package:boorusama/core/ui/tag_suggestion_items.dart';
import 'landing/trending/trending_section.dart';
import 'result/result_view.dart';

import 'package:boorusama/core/application/search_history.dart'
    hide SearchHistoryCleared;

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    required this.metatags,
    required this.metatagHighlightColor,
  });

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
  final focus = FocusNode();

  @override
  void dispose() {
    compositeSubscription.dispose();
    queryEditingController.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: _SmallLayout(
        focus: focus,
        queryEditingController: queryEditingController,
      ),
    );
  }
}

class _SelectedTagList extends ConsumerWidget {
  const _SelectedTagList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(selectedTagsProvider);

    return SelectedTagList(
      tags: tags,
      onClear: () => ref.selectedTagsNotifier.clear(),
      onDelete: (tag) => ref.searchNotifier.removeSelectedTag(tag),
      onBulkDownload: (tags) => goToBulkDownloadPage(
        context,
        tags.map((e) => e.toString()).toList(),
      ),
    );
  }
}

class _LandingView extends ConsumerWidget {
  const _LandingView({
    this.onFocusRequest,
    required this.onTextChanged,
  });

  final VoidCallback? onFocusRequest;
  final void Function(String text) onTextChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SearchLandingView(
      onAddTagRequest: () {
        final bloc = context.read<FavoriteTagBloc>();
        goToQuickSearchPage(
          context,
          onSubmitted: (context, text) {
            Navigator.of(context).pop();
            bloc.add(FavoriteTagAdded(tag: text));
          },
          onSelected: (tag) => bloc.add(FavoriteTagAdded(tag: tag.value)),
        );
      },
      trendingBuilder: (context) => TrendingSection(
        onTagTap: (value) {
          _onTagTap(context, value, ref);
        },
      ),
      onHistoryTap: (value) {
        FocusManager.instance.primaryFocus?.unfocus();
        ref.searchNotifier.tapTag(value);
      },
      onTagTap: (value) {
        _onTagTap(context, value, ref);
      },
      onHistoryRemoved: (value) => _onHistoryRemoved(ref, value),
      onHistoryCleared: () => _onHistoryCleared(ref),
      onFullHistoryRequested: () {
        goToSearchHistoryPage(
          context,
          onClear: () => _onHistoryCleared(ref),
          onRemove: (value) => _onHistoryRemoved(ref, value),
          onTap: (value) => _onHistoryTap(context, value, ref),
        );
      },
      metatagsBuilder: (context) => DanbooruMetatagsSection(
        onOptionTap: (value) {
          ref.read(searchProvider.notifier).tapRawMetaTag(value);
          onFocusRequest?.call();
          onTextChanged.call('$value:');
        },
      ),
    );
  }

  void _onTagTap(BuildContext context, String value, WidgetRef ref) {
    FocusManager.instance.primaryFocus?.unfocus();

    ref.searchNotifier.tapTag(value);
  }

  void _onHistoryTap(BuildContext context, String value, WidgetRef ref) {
    Navigator.of(context).pop();
    ref.searchNotifier.tapTag(value);
  }

  void _onHistoryCleared(WidgetRef ref) => ref.searchNotifier.clearHistories();

  void _onHistoryRemoved(WidgetRef ref, SearchHistory value) =>
      ref.searchNotifier.removeHistory(value);
}

class _AppBar extends StatelessWidget with PreferredSizeWidget {
  const _AppBar({
    required this.queryEditingController,
    this.focusNode,
  });

  final RichTextController queryEditingController;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shadowColor: Colors.transparent,
      automaticallyImplyLeading: false,
      toolbarHeight: kToolbarHeight * 1.2,
      title: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return _SearchBar(
            autofocus: state.settings.autoFocusSearchBar,
            focusNode: focusNode,
            queryEditingController: queryEditingController,
          );
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 1.2);
}

class _SmallLayout extends ConsumerWidget {
  const _SmallLayout({
    required this.focus,
    required this.queryEditingController,
  });

  final FocusNode focus;
  final RichTextController queryEditingController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayState = ref.watch(searchProvider);

    // listen to query provider
    ref.listen(
      sanitizedQueryProvider,
      (prev, curr) {
        if (prev != curr) {
          final displayState = ref.read(searchProvider);
          if (curr.isEmpty && displayState != DisplayState.result) {
            queryEditingController.clear();
          }
        }
      },
    );

    switch (displayState) {
      case DisplayState.options:
        return Scaffold(
          floatingActionButton: const _SearchButton(),
          appBar: _AppBar(
            focusNode: focus,
            queryEditingController: queryEditingController,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const _SelectedTagList(),
                  const _Divider(),
                  _LandingView(
                    onFocusRequest: () => focus.requestFocus(),
                    onTextChanged: (text) =>
                        _onTextChanged(queryEditingController, text),
                  ),
                ],
              ),
            ),
          ),
        );
      case DisplayState.suggestion:
        return Scaffold(
          appBar: _AppBar(
            focusNode: focus,
            queryEditingController: queryEditingController,
          ),
          body: SafeArea(
            child: Column(
              children: [
                const _SelectedTagList(),
                const _Divider(),
                Expanded(
                  child: _TagSuggestionItems(
                    queryEditingController: queryEditingController,
                  ),
                ),
              ],
            ),
          ),
        );

      case DisplayState.result:
        return ResultView(
          headerBuilder: () => [
            SliverAppBar(
              titleSpacing: 0,
              toolbarHeight: kToolbarHeight * 1.9,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              shadowColor: Colors.transparent,
              title: SizedBox(
                height: kToolbarHeight * 1.85,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SearchBar(
                        enabled: false,
                        onTap: () => ref.searchNotifier.goToSuggestions(),
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => ref.searchNotifier.resetToOptions(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const _SelectedTagList(),
                  ],
                ),
              ),
              floating: true,
              snap: true,
              automaticallyImplyLeading: false,
            ),
            const SliverToBoxAdapter(child: _Divider(height: 7)),
          ],
        );
    }
  }
}

class _SearchButton extends ConsumerWidget {
  const _SearchButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowSearch = ref.watch(allowSearchProvider);

    return allowSearch
        ? FloatingActionButton(
            onPressed: () {
              ref.searchNotifier.search();
              final tags = ref.read(selectedTagsProvider);
              final rawTags = tags.map((e) => e.toString()).toList();
              ref.read(postCountStateProvider.notifier).getPostCount(rawTags);
            },
            heroTag: null,
            child: const Icon(Icons.search),
          )
        : const SizedBox.shrink();
  }
}

void _onTextChanged(
  TextEditingController controller,
  String text,
) {
  controller
    ..text = text
    ..selection = TextSelection.collapsed(offset: controller.text.length);
}

class _TagSuggestionItems extends ConsumerWidget {
  const _TagSuggestionItems({
    required this.queryEditingController,
  });

  final TextEditingController queryEditingController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentQuery = ref.watch(searchQueryProvider);
    final suggestionTags = ref.watch(suggestionsProvider);
    final histories = context
        .select((SearchHistorySuggestionsBloc bloc) => bloc.state.histories);
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);

    return suggestionTags.maybeWhen(
      data: (data) => SliverTagSuggestionItemsWithHistory(
        tags: data,
        histories: histories,
        currentQuery: currentQuery,
        onHistoryDeleted: (history) {
          ref.searchNotifier.removeHistory(history.searchHistory);
        },
        onHistoryTap: (history) {
          FocusManager.instance.primaryFocus?.unfocus();
          ref.searchNotifier.tapTag(history.tag);
        },
        onItemTap: (tag) {
          FocusManager.instance.primaryFocus?.unfocus();
          ref.searchNotifier.tapTag(tag.value);
        },
        textColorBuilder: (tag) =>
            generateDanbooruAutocompleteTagColor(tag, theme),
      ),
      orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }
}

class _Divider extends ConsumerWidget {
  const _Divider({
    this.height,
  });

  final double? height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(selectedTagsProvider);
    return tags.isNotEmpty
        ? Divider(height: height ?? 15, thickness: 1)
        : const SizedBox.shrink();
  }
}

class _SearchBar extends ConsumerWidget {
  const _SearchBar({
    required this.queryEditingController,
    this.focusNode,
    this.autofocus = false,
  });

  final RichTextController queryEditingController;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayState = ref.watch(searchProvider);
    final currentQuery = ref.watch(searchQueryProvider);

    return SearchBar(
      autofocus: autofocus,
      focus: focusNode,
      queryEditingController: queryEditingController,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => displayState != DisplayState.options
            ? ref.searchNotifier.resetToOptions()
            : Navigator.of(context).pop(),
      ),
      trailing: currentQuery.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: () =>
                  ref.read(searchQueryProvider.notifier).state = '',
            )
          : const SizedBox.shrink(),
      onChanged: (value) {
        ref.read(searchQueryProvider.notifier).state = value;
      },
      onSubmitted: (value) {
        ref.searchNotifier.submit(value);
      },
    );
  }
}
