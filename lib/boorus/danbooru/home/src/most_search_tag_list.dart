// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/configs/ref.dart';
import '../../../../core/tags/tag/tag.dart';
import '../../../../core/tags/tag/widgets.dart';
import '../../../../core/theme/providers.dart';
import '../../tags/tag/widgets.dart';
import '../../tags/trending/providers.dart';

class MostSearchTagList extends ConsumerWidget {
  const MostSearchTagList({
    required this.onSelected,
    required this.selected,
    super.key,
  });

  final void Function(Tag search, bool value) onSelected;
  final String selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigFilter;

    return ref
        .watch(trendingTagsProvider(config))
        .when(
          data: (searches) => searches.isNotEmpty
              ? SizedBox(
                  height: 40,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: searches.length,
                    itemBuilder: (context, index) {
                      return DanbooruTagContextMenu(
                        tag: searches[index].name,
                        child: _Chip(
                          search: searches[index],
                          isSelected: selected == searches[index].rawName,
                          onSelected: (value) =>
                              onSelected(searches[index], value),
                        ),
                      );
                    },
                  ),
                )
              : const SizedBox.shrink(),
          error: (error, stackTrace) => const SizedBox.shrink(),
          loading: () => const TagChipsPlaceholder(),
        );
  }
}

class _Chip extends ConsumerWidget {
  const _Chip({
    required this.isSelected,
    required this.onSelected,
    required this.search,
  });

  final Tag search;
  final bool isSelected;
  final void Function(bool value) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(
      chipColorsFromTagStringProvider(
        (ref.watchConfigAuth, search.category.name),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        showCheckmark: false,
        disabledColor: Theme.of(context).chipTheme.disabledColor,
        backgroundColor:
            colors?.backgroundColor ??
            Theme.of(context).chipTheme.backgroundColor,
        selectedColor: Theme.of(context).colorScheme.onSurface,
        selected: isSelected,
        side: BorderSide(
          color: isSelected
              ? Colors.transparent
              : colors?.borderColor ?? Colors.transparent,
        ),
        onSelected: (selected) => onSelected(selected),
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        labelPadding: const EdgeInsets.all(1),
        visualDensity: VisualDensity.compact,
        label: Text(
          search.displayName,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.surface
                : colors?.foregroundColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
