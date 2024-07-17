// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:searchfield/searchfield.dart';

// Project imports:
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'providers.dart';

class BookmarkSearchBar extends ConsumerWidget {
  const BookmarkSearchBar({
    super.key,
    required this.focusNode,
    required this.controller,
  });

  final FocusNode focusNode;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasBookmarks = ref.watch(hasBookmarkProvider);

    if (!hasBookmarks) return const SizedBox.shrink();

    final selectedTag = ref.watch(selectedTagsProvider);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: SearchField(
        animationDuration: const Duration(milliseconds: 100),
        autoCorrect: false,
        focusNode: focusNode,
        marginColor: Colors.transparent,
        maxSuggestionsInViewPort: 10,
        offset: const Offset(0, 54),
        scrollbarDecoration: ScrollbarDecoration(
          thumbVisibility: false,
        ),
        itemHeight: kPreferredLayout.isMobile ? 42 : 40,
        suggestionsDecoration: SuggestionDecoration(
          color: context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        searchInputDecoration: InputDecoration(
          prefixIcon: const Icon(Symbols.search),
          suffix: selectedTag.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Material(
                    child: InkWell(
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(Symbols.clear, size: 18),
                      ),
                      onTap: () {
                        controller.clear();
                        ref.read(selectedTagsProvider.notifier).state = '';
                      },
                    ),
                  ),
                )
              : null,
          hintText: 'Filter...',
        ),
        controller: controller,
        onSuggestionTap: (p0) {
          ref.read(selectedTagsProvider.notifier).state = p0.searchKey;
          FocusScope.of(context).unfocus();
        },
        suggestions: ref
            .watch(tagSuggestionsProvider)
            .map(
              (e) => SearchFieldListItem(
                e,
                item: e,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: kPreferredLayout.isMobile ? 2 : 0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Html(
                          style: {
                            'p': Style(
                              fontSize: FontSize.medium,
                              color: ref.watch(tagColorProvider(e)).maybeWhen(
                                    data: (color) => color,
                                    orElse: () => null,
                                  ),
                              margin: Margins.zero,
                            ),
                            'body': Style(
                              margin: Margins.zero,
                            ),
                            'b': Style(
                              fontWeight: FontWeight.w900,
                            ),
                          },
                          data:
                              '<p>${e.replaceAll(selectedTag, '<b>$selectedTag</b>')}</p>',
                        ),
                      ),
                      Text(
                        ref.watch(tagCountProvider(e)).toString(),
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
