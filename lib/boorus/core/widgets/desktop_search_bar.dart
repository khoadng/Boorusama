// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/search/search.dart';
import 'package:boorusama/boorus/core/feats/utils.dart';
import 'package:boorusama/boorus/core/pages/search/metatags/danbooru_metatags_section.dart';
import 'package:boorusama/boorus/core/pages/search/search_app_bar.dart';
import 'package:boorusama/boorus/core/pages/search/search_landing_view.dart';
import 'package:boorusama/boorus/core/pages/search/selected_tag_list_with_data.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
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
  void initState() {
    super.initState();
    focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    showSuggestions.value = focusNode.hasFocus;
  }

  @override
  Widget build(BuildContext context) {
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
              portalFollower: SizedBox(
                width: min(600, MediaQuery.of(context).size.width),
                height: MediaQuery.of(context).size.height * 0.75,
                child: ValueListenableBuilder(
                  valueListenable: textEditingController,
                  builder: (context, query, child) {
                    final suggestionTags =
                        ref.watch(suggestionProvider(query.text));

                    return query.text.isNotEmpty
                        ? TagSuggestionItems(
                            backgroundColor:
                                Theme.of(context).colorScheme.background,
                            tags: suggestionTags,
                            currentQuery: query.text,
                            onItemTap: (tag) {
                              selectedTagController.addTag(tag.value);
                              textEditingController.clear();
                              showSuggestions.value = false;
                            },
                            textColorBuilder: (tag) =>
                                generateAutocompleteTagColor(
                                    tag, context.themeMode),
                          )
                        : Material(
                            color: context.colorScheme.background,
                            elevation: 4,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                            child: SearchLandingView(
                              onHistoryCleared: () => ref
                                  .read(searchHistoryProvider.notifier)
                                  .clearHistories(),
                              onHistoryRemoved: (value) => ref
                                  .read(searchHistoryProvider.notifier)
                                  .removeHistory(value.query),
                              onTagTap: (value) => selectedTagController.addTag(
                                value,
                                operator: getFilterOperator(
                                    textEditingController.text),
                              ),
                              onHistoryTap: (value) =>
                                  selectedTagController.addTag(value),
                              metatagsBuilder: (context) =>
                                  DanbooruMetatagsSection(
                                onOptionTap: (value) {
                                  textEditingController.text = '$value:';
                                  _onTextChanged('$value:');
                                },
                              ),
                            ),
                          );
                  },
                ),
              ),
              child: SearchAppBar(
                autofocus: false,
                focusNode: focusNode,
                queryEditingController: textEditingController,
                onChanged: (value) => ref
                    .read(suggestionsProvider.notifier)
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
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.search),
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
