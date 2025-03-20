// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../boorus/danbooru/posts/search/src/widgets/danbooru_metatags_section.dart';
import '../../../../boorus/booru/booru.dart';
import '../../../../configs/ref.dart';
import '../../../../foundation/display.dart';
import '../../../../foundation/platform.dart';
import '../../../../utils/flutter_utils.dart';
import '../../../queries/query_utils.dart';
import '../../../selected_tags/selected_tag_controller.dart';
import '../../../suggestions/suggestions_notifier.dart';
import '../../../suggestions/tag_suggestion_items.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final focusNode = FocusScope.of(context);
    final size = MediaQuery.sizeOf(context);

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
          final suggestionTags = ref.watch(suggestionProvider(query.text));

          return Stack(
            children: [
              if (query.text.isNotEmpty)
                TagSuggestionItems(
                  config: ref.watchConfigAuth,
                  dense: true,
                  backgroundColor: colorScheme.surfaceContainer,
                  tags: suggestionTags,
                  currentQuery: query.text,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ).copyWith(bottom: 4, top: 4),
                  onItemTap: (tag) {
                    selectedTagController.addTag(
                      tag.value,
                      operator: getFilterOperator(textEditingController.text),
                    );
                    textEditingController.clear();
                    showSuggestions.value = false;
                    focusNode.unfocus();
                  },
                )
              else
                Container(
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
                    reverseScheme: true,
                    backgroundColor: colorScheme.surfaceContainer,
                    onFavTagTap: (value) {
                      selectedTagController.addTagFromFavTag(value);
                      focusNode.unfocus();
                    },
                    onRawTagTap: (value) => selectedTagController.addTag(
                      value,
                      isRaw: true,
                    ),
                    onHistoryTap: (value) {
                      selectedTagController.addTagFromSearchHistory(value);
                      focusNode.unfocus();
                    },
                    metatags:
                        ref.watchConfigAuth.booruType == BooruType.danbooru
                            ? DanbooruMetatagsSection(
                                onOptionTap: (value) {
                                  textEditingController.text = '$value:';
                                  // ignore: cascade_invocations
                                  textEditingController
                                      .setTextAndCollapseSelection('$value:');
                                  setState(() {});
                                },
                              )
                            : null,
                  ),
                ),
              if (kPreferredLayout.isMobile)
                Positioned(
                  top: 4,
                  right: 4,
                  child: MaterialButton(
                    minWidth: 0,
                    color: colorScheme.secondaryContainer,
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
                        color: colorScheme.onSecondaryContainer,
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
