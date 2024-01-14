// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/search/search.dart';
import 'package:boorusama/core/pages/search/metatags/danbooru_metatags_section.dart';
import 'package:boorusama/core/pages/search/search_app_bar.dart';
import 'package:boorusama/core/pages/search/search_landing_view.dart';
import 'package:boorusama/core/pages/search/selected_tag_list_with_data.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/router.dart';
import 'widgets/search/result_view.dart';
import 'widgets/search/trending_section.dart';

class DanbooruSearchPage extends ConsumerStatefulWidget {
  const DanbooruSearchPage({
    super.key,
    this.initialQuery,
    this.selectedTagController,
    required this.searchBarLeading,
  });

  final String? initialQuery;
  final SelectedTagController? selectedTagController;
  final Widget? searchBarLeading;

  @override
  ConsumerState<DanbooruSearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<DanbooruSearchPage> {
  late final metaTagRegex =
      RegExp('(${ref.watch(metatagsProvider).map((e) => e.name).join('|')})+:');

  var selectedTagString = ValueNotifier('');

  @override
  void initState() {
    super.initState();

    if (widget.initialQuery != null) {
      selectedTagString.value = widget.initialQuery!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SearchScope(
      selectedTagController: widget.selectedTagController,
      initialQuery: widget.initialQuery,
      pattern: {
        metaTagRegex: TextStyle(
          fontWeight: FontWeight.w800,
          color: context.colorScheme.primary,
        ),
      },
      builder: (state, focus, controller, selectedTagController,
              searchController, allowSearch) =>
          ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, value, child) => Stack(
          children: [
            Offstage(
              offstage: value.text.isNotEmpty,
              child: ResultView(
                selectedTagString: selectedTagString,
                selectedTagController: selectedTagController,
                onRelatedTagSelected: (tag, postController) {
                  selectedTagController.addTag(tag.tag);
                  postController.refresh();
                  selectedTagString.value = selectedTagController.rawTagsString;
                  searchController.search();
                },
                headerBuilder: (postController) => [
                  const SliverAppAnnouncementBanner(),
                  SliverToBoxAdapter(
                    child: SearchAppBar(
                      focusNode: focus,
                      queryEditingController: controller,
                      onSubmitted: (value) => searchController.submit(value),
                      leading: widget.searchBarLeading ??
                          (!context.canPop()
                              ? null
                              : const SearchAppBarBackButton()),
                      innerSearchButton: value.text.isEmpty
                          ? InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () {
                                searchController.search();
                                postController.refresh();
                                selectedTagString.value =
                                    selectedTagController.rawTagsString;
                                ref
                                    .read(danbooruRelatedTagProvider.notifier)
                                    .getRelatedTag(
                                        selectedTagController.rawTagsString);
                              },
                              child: Container(
                                margin: const EdgeInsets.all(12),
                                child: const Icon(
                                  Symbols.search,
                                ),
                              ),
                            )
                          : null,
                      trailingSearchButton: IconButton(
                        onPressed: () => showBarModalBottomSheet(
                          context: context,
                          builder: (context) => Scaffold(
                            body: SafeArea(
                              child: CustomScrollView(
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: SearchLandingView(
                                      onHistoryCleared: () => ref
                                          .read(searchHistoryProvider.notifier)
                                          .clearHistories(),
                                      onHistoryRemoved: (value) => ref
                                          .read(searchHistoryProvider.notifier)
                                          .removeHistory(value.query),
                                      onHistoryTap: (value) {
                                        searchController.tapHistoryTag(value);
                                      },
                                      onTagTap: (value) {
                                        searchController.tapTag(value);
                                        context.pop();
                                      },
                                      trendingBuilder: (context) =>
                                          TrendingSection(
                                        onTagTap: (value) {
                                          searchController.tapTag(value);
                                          context.pop();
                                        },
                                      ),
                                      metatagsBuilder: (context) =>
                                          DanbooruMetatagsSection(
                                        onOptionTap: (value) {
                                          searchController.tapRawMetaTag(value);
                                          focus.requestFocus();
                                          _onTextChanged(controller, '$value:');
                                          context.pop();
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        icon: const Icon(Symbols.sort),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                      child: SelectedTagListWithData(
                    controller: selectedTagController,
                  )),
                ],
              ),
            ),
            Offstage(
              offstage: value.text.isEmpty,
              child: Scaffold(
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight * 1.2),
                  child: SearchAppBar(
                    focusNode: focus,
                    queryEditingController: controller,
                    onSubmitted: (value) => searchController.submit(value),
                    leading: widget.searchBarLeading ??
                        (!context.canPop()
                            ? null
                            : const SearchAppBarBackButton()),
                  ),
                ),
                body: DefaultSearchSuggestionView(
                  textEditingController: controller,
                  searchController: searchController,
                  selectedTagController: selectedTagController,
                ),
              ),
            )
          ],
        ),
      ),
    );
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
