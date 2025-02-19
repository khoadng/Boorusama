// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:searchfield/searchfield.dart';

// Project imports:
import '../../../foundation/display.dart';
import '../../../foundation/html.dart';
import '../../../theme.dart';
import '../providers/bookmark_provider.dart';
import '../providers/local_providers.dart';

class BookmarkSearchBar extends ConsumerWidget {
  const BookmarkSearchBar({
    required this.focusNode,
    required this.controller,
    super.key,
  });

  final FocusNode focusNode;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasBookmarks = ref.watch(hasBookmarkProvider);

    if (!hasBookmarks) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 12,
      ),
      height: kPreferredLayout.isDesktop ? 34 : null,
      child: SearchField(
        animationDuration: const Duration(milliseconds: 100),
        autoCorrect: false,
        focusNode: focusNode,
        marginColor: Colors.transparent,
        maxSuggestionsInViewPort: 10,
        offset: kPreferredLayout.isDesktop
            ? const Offset(0, 40)
            : const Offset(0, 54),
        scrollbarDecoration: ScrollbarDecoration(
          thumbVisibility: false,
        ),
        itemHeight: kPreferredLayout.isMobile ? 42 : 40,
        suggestionsDecoration: SuggestionDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        searchInputDecoration: SearchInputDecoration(
          cursorColor: Theme.of(context).colorScheme.primary,
          prefixIcon: const Icon(Symbols.search),
          suffixIcon: ValueListenableBuilder(
            valueListenable: controller,
            builder: (_, value, ___) => value.text.isNotEmpty
                ? InkWell(
                    child: const Icon(Symbols.clear),
                    onTap: () {
                      controller.clear();
                      ref.read(selectedTagsProvider.notifier).state = '';
                    },
                  )
                : const SizedBox.shrink(),
          ),
          hintText: 'Filter...',
        ),
        controller: controller,
        onTapOutside: (_) {
          focusNode.unfocus();
        },
        onSuggestionTap: (p0) {
          ref.read(selectedTagsProvider.notifier).state = '${p0.searchKey} ';
        },
        suggestions: ref
            .watch(tagSuggestionsProvider)
            .map((e) => _buildItem(e, ref))
            .toList(),
      ),
    );
  }

  SearchFieldListItem<String> _buildItem(String tag, WidgetRef ref) {
    final context = ref.context;

    return SearchFieldListItem(
      tag,
      item: tag,
      child: IgnorePointer(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 4,
            vertical: kPreferredLayout.isMobile ? 2 : 0,
          ),
          child: Row(
            children: [
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: controller,
                  builder: (_, value, ___) => AppHtml(
                    style: {
                      'p': Style(
                        fontSize: FontSize.medium,
                        color:
                            ref.watch(bookmarkTagColorProvider(tag)).maybeWhen(
                                  data: (color) => color,
                                  orElse: () => null,
                                ),
                        margin: Margins.zero,
                      ),
                      'b': Style(
                        fontWeight: FontWeight.w900,
                      ),
                    },
                    data:
                        '<p>${tag.replaceAll(value.text, '<b>${value.text}</b>')}</p>',
                  ),
                ),
              ),
              Text(
                ref.watch(tagCountProvider(tag)).toString(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.hintColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
