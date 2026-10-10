// Dart imports:
import 'dart:math';

// Package imports:
import 'package:anchor_ui/anchor_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../../../../boorus/danbooru/posts/search/src/widgets/danbooru_metatags_section.dart';
import '../../../../../foundation/app_update/widgets.dart';
import '../../../../../foundation/utils/flutter_utils.dart';
import '../../../../boorus/booru/types.dart';
import '../../../../configs/config/providers.dart';
import '../../../../tags/autocompletes/types.dart';
import '../../../../tags/metatag/providers.dart';
import '../../../queries/types.dart';
import '../../../selected_tags/providers.dart';
import '../../../selected_tags/types.dart';
import '../../../suggestions/providers.dart';
import '../../../suggestions/widgets.dart';
import '../../../syntax/providers.dart';
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
  late final textEditingController = RichTextController(
    matchers: [?ref.read(queryMatcherProvider(ref.readConfigAuth))],
  );
  late final selectedTagController = widget.selectedTagController;
  final focus = FocusNode();
  final suggestionsFocus = FocusScopeNode(
    debugLabel: 'DesktopSearchSuggestions',
  );
  final suggestionsListbox = KurumiListboxController();

  @override
  void dispose() {
    textEditingController.dispose();
    focus.dispose();
    suggestionsFocus.dispose();
    suggestionsListbox.dispose();
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
      suggestionsFocus: suggestionsFocus,
      listbox: suggestionsListbox,
      height: kToolbarHeight * 0.9,
      controller: textEditingController,
      searchBarBuilder: (context, child) => AnchorPopover(
        triggerMode: AnchorTriggerMode.focus(
          focusNode: focus,
        ),
        arrowShape: const NoArrow(),
        placement: Placement.bottomStart,
        fitToAvailableSpace: true,
        spacing: 4,
        overlayBuilder: (context) => _buildOverlay(focus),
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
        color: Kurumi.themeOf(context).colorScheme.surface,
        shape: const CircleBorder(),
        onPressed: widget.onSearch,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(
            Symbols.search,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _addSuggestion(AutocompleteData tag) {
    final operator = getFilterOperator(textEditingController.text);
    selectedTagController.addTag(
      TagSearchItem.fromString(
        '$operator${tag.value}',
        extractor: ref.read(metatagExtractorProvider(ref.readConfigAuth)),
      ),
    );
    textEditingController.clear();
  }

  Widget _buildOverlay(FocusNode focusNode) => Actions(
    actions: {
      DirectionalFocusIntent: _ReturnToFieldAction(focusNode),
    },
    child: FocusScope(
      node: suggestionsFocus,
      child: _buildSuggestions(focusNode),
    ),
  );

  Widget _buildSuggestions(FocusNode focusNode) {
    final colorScheme = Kurumi.themeOf(context).colorScheme;
    final size = MediaQuery.sizeOf(context);
    final auth = ref.watchConfigAuth;

    return Container(
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
            suggestionProvider((auth, query.text)),
          );

          return query.text.isNotEmpty
              ? TagSuggestionItems(
                  config: auth,
                  dense: true,
                  backgroundColor: colorScheme.surfaceContainer,
                  tags: suggestionTags,
                  currentQuery: query.text,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ).copyWith(bottom: 4, top: 4),
                  listbox: suggestionsListbox,
                  onItemPick: _addSuggestion,
                  onItemTap: (tag) {
                    _addSuggestion(tag);
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
                        DefaultQueryActionsSection(
                          onTagAdded: (value) => selectedTagController.addTag(
                            TagSearchItem.raw(tag: value),
                          ),
                        ),
                        //FIXME: move this out of here
                        if (auth.booruType == BooruType.danbooru)
                          DanbooruMetatagsSection(
                            onOptionTap: (value) {
                              textEditingController.text = '$value:';
                              textEditingController.setTextAndCollapseSelection(
                                '$value:',
                              );
                              setState(() {});
                            },
                          ),
                        DefaultFavoriteTagsSection(
                          onTagTap: (value) {
                            selectedTagController.addTagFromFavTag(value);
                            focusNode.unfocus();
                          },
                        ),
                        DefaultSearchHistorySection(
                          reverseScheme: true,
                          onHistoryTap: (value) {
                            selectedTagController.addTagFromSearchHistory(
                              value,
                            );
                            focusNode.unfocus();
                          },
                        ),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }
}

/// Up past the first suggestion returns to the search field so typing can
/// continue; other arrows move between suggestions as usual.
class _ReturnToFieldAction extends KurumiDirectionalFocusAction {
  _ReturnToFieldAction(this.field);

  final FocusNode field;

  @override
  void invoke(DirectionalFocusIntent intent) {
    if (intent.direction != TraversalDirection.up) {
      return super.invoke(intent);
    }

    final moved =
        primaryFocus?.focusInDirection(TraversalDirection.up) ?? false;
    if (!moved) field.requestFocus();
  }
}
