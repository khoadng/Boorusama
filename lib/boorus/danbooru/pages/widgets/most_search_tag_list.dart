// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/theme/theme.dart';
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
    final asyncData = ref.watch(trendingTagsProvider(config));

    return asyncData.when(
      data: (searches) => searches.isNotEmpty
          ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: searches.length,
                itemBuilder: (context, index) {
                  return _Chip(
                    search: searches[index],
                    isSelected: selected == searches[index].keyword,
                    onSelected: onSelected,
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
                  ? generateChipColors(
                      ref.getTagColor(context, data.name),
                      context.themeMode,
                    )
                  : null,
              orElse: () => null,
            );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        disabledColor: context.theme.chipTheme.disabledColor,
        backgroundColor:
            colors?.backgroundColor ?? context.theme.chipTheme.backgroundColor,
        selectedColor: context.theme.chipTheme.selectedColor,
        selected: isSelected,
        side: BorderSide(
          width: 1.5,
          color: isSelected
              ? context.themeMode.isDark
                  ? Colors.white
                  : Colors.black
              : colors?.borderColor ?? Colors.transparent,
        ),
        onSelected: (selected) => onSelected(search),
        padding: const EdgeInsets.all(4),
        labelPadding: const EdgeInsets.all(1),
        visualDensity: VisualDensity.compact,
        label: Text(
          search.keyword.replaceUnderscoreWithSpace(),
          style: TextStyle(
            color: isSelected
                ? context.themeMode.isDark
                    ? Colors.black
                    : Colors.white
                : colors?.foregroundColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
