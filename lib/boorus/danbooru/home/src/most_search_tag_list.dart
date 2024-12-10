// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/settings/data.dart';
import 'package:boorusama/core/tags/tag/providers.dart';
import 'package:boorusama/core/tags/tag/widgets.dart';
import 'package:boorusama/core/theme/utils.dart';
import '../../tags/tag/providers.dart';
import '../../tags/tag/widgets.dart';
import '../../tags/trending/providers.dart';
import '../../tags/trending/trending.dart';

class MostSearchTagList extends ConsumerWidget {
  const MostSearchTagList({
    super.key,
    required this.onSelected,
    required this.selected,
  });

  final void Function(Search search, bool value) onSelected;
  final String selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;

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

  final Search search;
  final bool isSelected;
  final void Function(bool value) onSelected;

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
        disabledColor: Theme.of(context).chipTheme.disabledColor,
        backgroundColor: colors?.backgroundColor ??
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
          search.keyword.replaceAll('_', ' '),
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
