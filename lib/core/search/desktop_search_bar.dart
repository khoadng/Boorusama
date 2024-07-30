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
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/core/search_histories/search_histories.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/theme.dart';

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
                  offset: Offset(-32, 0),
                ),
                portalFollower: _buildOverlay(),
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
    final config = ref.watchConfig;

    return SearchAppBar(
      dense: true,
      autofocus: false,
      height: kToolbarHeight * 0.9,
      queryEditingController: textEditingController,
      onFocusChanged: (value) => showSuggestions.value = value,
      onChanged: (value) =>
          ref.read(suggestionsProvider(config).notifier).getSuggestions(value),
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

  Widget _buildOverlay() {
    return Container(
      constraints: BoxConstraints(
        maxWidth: min(context.screenWidth * 0.8, 500),
        maxHeight: min(context.screenHeight * 0.8, 400),
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
                      backgroundColor:
                          context.colorScheme.surfaceContainerHighest,
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
                        color: context.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SearchLandingView(
                        backgroundColor:
                            context.colorScheme.surfaceContainerHighest,
                        onHistoryCleared: () => ref
                            .read(searchHistoryProvider.notifier)
                            .clearHistories(),
                        onHistoryRemoved: (value) => ref
                            .read(searchHistoryProvider.notifier)
                            .removeHistory(value.query),
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
                          selectedTagController.addTags(value.split(' '));
                          FocusScope.of(context).unfocus();
                        },
                        metatagsBuilder: (context) => DanbooruMetatagsSection(
                          onOptionTap: (value) {
                            textEditingController.text = '$value:';
                            textEditingController
                                .setTextAndCollapseSelection('$value:');
                            setState(() {});
                          },
                        ),
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
