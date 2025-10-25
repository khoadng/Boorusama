// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_anchor/flutter_anchor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../boorus/danbooru/posts/search/src/widgets/danbooru_metatags_section.dart';
import '../../../../../foundation/app_update/widgets.dart';
import '../../../../../foundation/utils/flutter_utils.dart';
import '../../../../boorus/booru/types.dart';
import '../../../../configs/config/providers.dart';
import '../../../../tags/metatag/providers.dart';
import '../../../queries/types.dart';
import '../../../selected_tags/providers.dart';
import '../../../selected_tags/types.dart';
import '../../../suggestions/providers.dart';
import '../../../suggestions/widgets.dart';
import '../types/constants.dart';
import '../views/search_landing_view.dart';
import 'search_app_bar.dart';
import 'selected_tag_list_with_data.dart';

class DesktopSearchbar extends ConsumerStatefulWidget {
  const DesktopSearchbar({
    required this.onSearch,
    required this.selectedTagController,
    super.key,
  });

  final void Function() onSearch;
  final SelectedTagController selectedTagController;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DesktopSearchbarState();
}

class _DesktopSearchbarState extends ConsumerState<DesktopSearchbar> {
  final textEditingController = TextEditingController();
  late final selectedTagController = widget.selectedTagController;
  final focus = FocusNode();

  @override
  void dispose() {
    textEditingController.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        Consumer(
          builder: (context, ref, child) => SelectedTagListWithData(
            controller: selectedTagController,
            flexibleBorderPosition: false,
            config: ref.watchConfig,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    final config = ref.watchConfigAuth;

    return SearchAppBar(
      dense: true,
      autofocus: false,
      focusNode: focus,
      height: kToolbarHeight * 0.9,
      controller: textEditingController,
      searchBarBuilder: (context, child) => AnchorPopover(
        triggerMode: AnchorTriggerMode.focus(
          focusNode: focus,
        ),
        arrowShape: const NoArrow(),
        placement: Placement.bottomStart,
        spacing: 4,
        overlayBuilder: (context) => LayoutBuilder(
          builder: (context, constraints) => _buildOverlay(constraints),
        ),
        child: child,
      ),
      onTapOutside: () {
        //TODO: remove onTapOutside workaround since using flutter_anchor, this is not needed
      },
      onChanged: (value) => ref
          .read(suggestionsNotifierProvider(config).notifier)
          .getSuggestions(value),
      onSubmitted: (value) {
        selectedTagController.addTag(
          TagSearchItem.fromString(
            value,
            extractor: ref.read(metatagExtractorProvider(config)),
          ),
        );
        textEditingController.clear();

        widget.onSearch();
      },
      leading: null,
      innerSearchButton: const AppUpdateButton(),
      trailingSearchButton: MaterialButton(
        minWidth: 0,
        elevation: 0,
        color: Theme.of(context).cardColor,
        shape: const CircleBorder(),
        onPressed: () => widget.onSearch(),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Symbols.search, size: 20),
        ),
      ),
    );
  }

  Widget _buildOverlay(BoxConstraints constraints) {
    final colorScheme = Theme.of(context).colorScheme;
    final focusNode = FocusScope.of(context);
    final size = MediaQuery.sizeOf(context);

    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: min(
            size.width * 0.7,
            kSearchAppBarWidth,
          ),
          maxHeight: min(size.height * 0.8, 400),
        ),
        child: ValueListenableBuilder(
          valueListenable: textEditingController,
          builder: (context, query, child) {
            final suggestionTags = ref.watch(
              suggestionProvider((ref.watchConfigAuth, query.text)),
            );

            return query.text.isNotEmpty
                ? TagSuggestionItems(
                    config: ref.watchConfigAuth,
                    dense: true,
                    backgroundColor: colorScheme.surfaceContainer,
                    tags: suggestionTags,
                    currentQuery: query.text,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                    ).copyWith(bottom: 4, top: 4),
                    onItemTap: (tag) {
                      final operator = getFilterOperator(
                        textEditingController.text,
                      );
                      final operatorPrefix = operator.toString();
                      selectedTagController.addTag(
                        TagSearchItem.fromString(
                          '$operatorPrefix${tag.value}',
                          extractor: ref.watch(
                            metatagExtractorProvider(
                              ref.watchConfigAuth,
                            ),
                          ),
                        ),
                      );
                      textEditingController.clear();
                      focusNode.unfocus();
                    },
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SearchLandingView(
                      disableAnimation: true,
                      reverse: false,
                      backgroundColor: colorScheme.surfaceContainer,
                      child: DefaultSearchLandingChildren(
                        reverse: false,
                        children: [
                          DefaultDesktopQueryActionsSection(
                            selectedTagController: selectedTagController,
                          ),
                          if (ref.watchConfigAuth.booruType ==
                              BooruType.danbooru)
                            DanbooruMetatagsSection(
                              onOptionTap: (value) {
                                textEditingController.text = '$value:';
                                textEditingController
                                    .setTextAndCollapseSelection(
                                      '$value:',
                                    );
                                setState(() {});
                              },
                            ),
                          DefaultDesktopFavoriteTagsSection(
                            selectedTagController: selectedTagController,
                            focusNode: focusNode,
                          ),
                          DefaultDesktopSearchHistorySection(
                            selectedTagController: selectedTagController,
                            focusNode: focusNode,
                          ),
                        ],
                      ),
                    ),
                  );
          },
        ),
      ),
    );
  }
}

class DefaultDesktopSearchHistorySection extends StatelessWidget {
  const DefaultDesktopSearchHistorySection({
    super.key,
    required this.selectedTagController,
    required this.focusNode,
  });

  final SelectedTagController selectedTagController;
  final FocusScopeNode focusNode;

  @override
  Widget build(BuildContext context) {
    return DefaultSearchHistorySection(
      reverseScheme: true,
      onHistoryTap: (value) {
        selectedTagController.addTagFromSearchHistory(value);
        focusNode.unfocus();
      },
    );
  }
}

class DefaultDesktopFavoriteTagsSection extends StatelessWidget {
  const DefaultDesktopFavoriteTagsSection({
    super.key,
    required this.selectedTagController,
    required this.focusNode,
  });

  final SelectedTagController selectedTagController;
  final FocusScopeNode focusNode;

  @override
  Widget build(BuildContext context) {
    return DefaultFavoriteTagsSection(
      onTagTap: (value) {
        selectedTagController.addTagFromFavTag(value);
        focusNode.unfocus();
      },
    );
  }
}

class DefaultDesktopQueryActionsSection extends StatelessWidget {
  const DefaultDesktopQueryActionsSection({
    super.key,
    required this.selectedTagController,
  });

  final SelectedTagController selectedTagController;

  @override
  Widget build(BuildContext context) {
    return DefaultQueryActionsSection(
      onTagAdded: (value) => selectedTagController.addTag(
        TagSearchItem.raw(tag: value),
      ),
    );
  }
}
