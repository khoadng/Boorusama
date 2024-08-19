// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/tags/tags.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/string.dart';

class MostSearchTagList extends ConsumerWidget {
  const MostSearchTagList({
    super.key,
    required this.onSelected,
    required this.selected,
  });

  final void Function(Search search) onSelected;
  final String selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;

    return ref.watch(trendingTagsProvider(config)).when(
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
                        tag: searches[index].keyword,
                        child: _Chip(
                          search: searches[index],
                          isSelected: selected == searches[index].keyword,
                          onSelected: onSelected,
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

  final Search search;
  final bool isSelected;
  final void Function(Search search) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors =
        ref.watch(danbooruTagCategoryProvider(search.keyword)).maybeWhen(
              data: (data) => data != null
                  ? context.generateChipColors(
                      ref.watch(tagColorProvider(data.name)),
                      ref.watch(settingsProvider),
                    )
                  : null,
              orElse: () => null,
            );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        showCheckmark: false,
        disabledColor: context.theme.chipTheme.disabledColor,
        backgroundColor:
            colors?.backgroundColor ?? context.theme.chipTheme.backgroundColor,
        selectedColor: context.colorScheme.onSurface,
        selected: isSelected,
        side: BorderSide(
          color: isSelected
              ? Colors.transparent
              : colors?.borderColor ?? Colors.transparent,
        ),
        onSelected: (selected) => onSelected(search),
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        labelPadding: const EdgeInsets.all(1),
        visualDensity: VisualDensity.compact,
        label: Text(
          search.keyword.replaceUnderscoreWithSpace(),
          style: TextStyle(
            color: isSelected
                ? context.colorScheme.surface
                : colors?.foregroundColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
