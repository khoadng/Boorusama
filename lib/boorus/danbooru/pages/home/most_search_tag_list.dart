// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/utils.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/theme/theme_mode.dart';

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
    final asyncData = ref.watch(trendingTagsProvider);
    final theme = ref.watch(themeProvider);

    return asyncData.when(
      data: (searches) => searches.isNotEmpty
          ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              height: 40,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: searches.length,
                itemBuilder: (context, index) {
                  final isSelected = selected == searches[index].keyword;
                  final search = searches[index];
                  final category =
                      ref.watch(danbooruTagCategoryProvider(search.keyword));

                  final colors = category == null
                      ? null
                      : generateChipColors(getTagColor(category, theme), theme);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      disabledColor: context.theme.chipTheme.disabledColor,
                      backgroundColor: colors?.backgroundColor ??
                          context.theme.chipTheme.backgroundColor,
                      selectedColor: context.theme.chipTheme.selectedColor,
                      selected: isSelected,
                      side: BorderSide(
                        width: 1.5,
                        color: isSelected
                            ? theme.isDark
                                ? Colors.white
                                : Colors.black
                            : colors?.borderColor ?? Colors.transparent,
                      ),
                      onSelected: (selected) => onSelected(searches[index]),
                      padding: const EdgeInsets.all(4),
                      labelPadding: const EdgeInsets.all(1),
                      visualDensity: VisualDensity.compact,
                      label: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.85,
                        ),
                        child: Text(
                          searches[index].keyword.removeUnderscoreWithSpace(),
                          style: TextStyle(
                            color: isSelected
                                ? theme.isDark
                                    ? Colors.black
                                    : Colors.white
                                : colors?.foregroundColor,
                          ),
                          overflow: TextOverflow.fade,
                        ),
                      ),
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
