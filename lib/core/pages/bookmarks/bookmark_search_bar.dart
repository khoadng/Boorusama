// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:searchfield/searchfield.dart';

// Project imports:
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

    return Padding(
      padding: const EdgeInsets.all(8),
      child: SearchField(
        focusNode: focusNode,
        maxSuggestionsInViewPort: 10,
        searchInputDecoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          suffix: ref.watch(selectedTagsProvider).isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Material(
                    child: InkWell(
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(Icons.clear, size: 18),
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
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          e,
                          style: TextStyle(
                            color: ref.watch(tagColorProvider(e)).maybeWhen(
                                  data: (color) => color,
                                  orElse: () => null,
                                ),
                          ),
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
