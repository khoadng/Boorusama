// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/search/search.dart';
import 'package:boorusama/core/feats/utils.dart';
import 'package:boorusama/core/pages/search/metatags/danbooru_metatags_section.dart';
import 'package:boorusama/core/pages/search/search_app_bar.dart';
import 'package:boorusama/core/pages/search/search_landing_view.dart';
import 'package:boorusama/core/pages/search/selected_tag_list_with_data.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';

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
  final focusNode = FocusNode();
  late final selectedTagController = widget.selectedTagController;

  @override
  void dispose() {
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.readConfig;

    return ValueListenableBuilder(
      valueListenable: showSuggestions,
      builder: (context, show, child) {
        return Column(
          children: [
            PortalTarget(
              visible: show,
              anchor: const Aligned(
                follower: Alignment.topCenter,
                target: Alignment.bottomCenter,
                offset: Offset(-32, 0),
              ),
              portalFollower: Container(
                constraints: BoxConstraints(
                    maxWidth: min(context.screenWidth * 0.8, 500),
                    maxHeight: min(context.screenHeight * 0.8, 400)),
                child: ValueListenableBuilder(
                  valueListenable: textEditingController,
                  builder: (context, query, child) {
                    final suggestionTags =
                        ref.watch(suggestionProvider(query.text));

                    return Stack(
                      children: [
                        query.text.isNotEmpty
                            ? TagSuggestionItems(
                                dense: true,
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface,
                                tags: suggestionTags,
                                currentQuery: query.text,
                                onItemTap: (tag) {
                                  selectedTagController.addTag(
                                    tag.value,
                                    operator: getFilterOperator(
                                        textEditingController.text),
                                  );
                                  textEditingController.clear();
                                  showSuggestions.value = false;
                                  focusNode.unfocus();
                                },
                                textColorBuilder: (tag) =>
                                    generateAutocompleteTagColor(
                                        ref, context, tag),
                              )
                            : Material(
                                elevation: 4,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8)),
                                child: SearchLandingView(
                                  backgroundColor: context.colorScheme.surface,
                                  onHistoryCleared: () => ref
                                      .read(searchHistoryProvider.notifier)
                                      .clearHistories(),
                                  onHistoryRemoved: (value) => ref
                                      .read(searchHistoryProvider.notifier)
                                      .removeHistory(value.query),
                                  onTagTap: (value) =>
                                      selectedTagController.addTag(
                                    value,
                                    operator: getFilterOperator(
                                        textEditingController.text),
                                  ),
                                  onHistoryTap: (value) => selectedTagController
                                      .addTags(value.split(' ')),
                                  metatagsBuilder: (context) =>
                                      DanbooruMetatagsSection(
                                    onOptionTap: (value) {
                                      textEditingController.text = '$value:';
                                      _onTextChanged('$value:');
                                    },
                                  ),
                                ),
                              ),
                        if (isMobilePlatform())
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
                                focusNode.unfocus();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Symbols.close,
                                  color:
                                      context.colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              child: SearchAppBar(
                dense: true,
                autofocus: false,
                height: kToolbarHeight * 0.9,
                focusNode: focusNode,
                queryEditingController: textEditingController,
                onFocusChanged: (value) => showSuggestions.value = value,
                onChanged: (value) => ref
                    .read(suggestionsProvider(config).notifier)
                    .getSuggestions(value),
                onSubmitted: (value) {
                  selectedTagController.addTag(value);
                  textEditingController.clear();
                  showSuggestions.value = false;

                  widget.onSearch();
                },
                onBack: null,
                trailingSearchButton: MaterialButton(
                  minWidth: 0,
                  color: Theme.of(context).cardColor,
                  shape: const CircleBorder(),
                  onPressed: () => widget.onSearch(),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Symbols.search, size: 20),
                  ),
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

  void _onTextChanged(
    String text,
  ) {
    textEditingController
      ..text = text
      ..selection =
          TextSelection.collapsed(offset: textEditingController.text.length);
  }
}
