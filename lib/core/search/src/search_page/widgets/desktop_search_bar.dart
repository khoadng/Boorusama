// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/autocompletes/autocompletes.dart';
import 'package:boorusama/core/configs.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme.dart';
import '../../histories/providers.dart';
import '../../queries/query_utils.dart';
import '../../selected_tags/selected_tag_controller.dart';
import '../../suggestions/suggestions_notifier.dart';
import '../../suggestions/tag_suggestion_items.dart';
import '../search_landing_view.dart';
import '../selected_tag_list_with_data.dart';
import 'search_app_bar.dart';

class DesktopSearchbar extends ConsumerStatefulWidget {
  const DesktopSearchbar({
    super.key,
    required this.onSearch,
    required this.selectedTagController,
  });

  final void Function() onSearch;
  final SelectedTagController selectedTagController;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DesktopSearchbarState();
}

class _DesktopSearchbarState extends ConsumerState<DesktopSearchbar> {
  final textEditingController = TextEditingController();
  final showSuggestions = ValueNotifier(false);
  late final selectedTagController = widget.selectedTagController;

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: showSuggestions,
      builder: (context, show, child) {
        return Column(
          children: [
            FocusScope(
              child: PortalTarget(
                visible: show,
                anchor: const Aligned(
                  follower: Alignment.topCenter,
                  target: Alignment.bottomCenter,
                  offset: Offset(-28, 0),
                ),
                portalFollower: LayoutBuilder(
                  builder: (context, constraints) => _buildOverlay(constraints),
                ),
                child: Focus(
                  onFocusChange: (value) => showSuggestions.value = value,
                  child: _buildSearchBar(),
                ),
              ),
            ),
            SelectedTagListWithData(
              controller: selectedTagController,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    final config = ref.watchConfigAuth;

    return SearchAppBar(
      dense: true,
      autofocus: false,
      height: kToolbarHeight * 0.9,
      controller: textEditingController,
      onFocusChanged: (value) => showSuggestions.value = value,
      onTapOutside: isDesktopPlatform()
          ? () {
              showSuggestions.value = false;
              FocusScope.of(context).unfocus();
            }
          : null,
      onChanged: (value) => ref
          .read(suggestionsNotifierProvider(config).notifier)
          .getSuggestions(value),
      onSubmitted: (value) {
        selectedTagController.addTag(value);
        textEditingController.clear();
        showSuggestions.value = false;

        widget.onSearch();
      },
      leading: null,
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
    return Container(
      constraints: BoxConstraints(
        maxWidth: min(
          context.screenWidth * 0.7,
          500,
        ),
        maxHeight: min(context.screenHeight * 0.8, 500),
      ),
      child: ValueListenableBuilder(
        valueListenable: textEditingController,
        builder: (context, query, child) {
          final suggestionTags = ref.watch(suggestionProvider(query.text));

          return Stack(
            children: [
              query.text.isNotEmpty
                  ? TagSuggestionItems(
                      dense: true,
                      backgroundColor: context.colorScheme.surfaceContainer,
                      tags: suggestionTags,
                      currentQuery: query.text,
                      onItemTap: (tag) {
                        selectedTagController.addTag(
                          tag.value,
                          operator:
                              getFilterOperator(textEditingController.text),
                        );
                        textEditingController.clear();
                        showSuggestions.value = false;
                        FocusScope.of(context).unfocus();
                      },
                      textColorBuilder: (tag) =>
                          generateAutocompleteTagColor(ref, context, tag),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: context.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SearchLandingView(
                        disableAnimation: true,
                        reverseScheme: true,
                        backgroundColor: context.colorScheme.surfaceContainer,
                        onHistoryCleared: () => ref
                            .read(searchHistoryProvider.notifier)
                            .clearHistories(),
                        onHistoryRemoved: (value) => ref
                            .read(searchHistoryProvider.notifier)
                            .removeHistory(value),
                        onTagTap: (value) {
                          selectedTagController.addTag(
                            value,
                            operator:
                                getFilterOperator(textEditingController.text),
                          );
                          FocusScope.of(context).unfocus();
                        },
                        onRawTagTap: (value) => selectedTagController.addTag(
                          value,
                          isRaw: true,
                        ),
                        onHistoryTap: (value) {
                          selectedTagController.addTagFromSearchHistory(value);
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
              if (kPreferredLayout.isMobile)
                Positioned(
                  top: 4,
                  right: 4,
                  child: MaterialButton(
                    minWidth: 0,
                    color: context.colorScheme.secondaryContainer,
                    shape: const CircleBorder(),
                    onPressed: () {
                      textEditingController.clear();
                      showSuggestions.value = false;
                      FocusScope.of(context).unfocus();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Symbols.close,
                        color: context.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
