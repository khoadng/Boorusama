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
import 'package:boorusama/flutter.dart';

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

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      disabledColor: context.theme.chipTheme.disabledColor,
                      backgroundColor: category == null
                          ? context.theme.chipTheme.backgroundColor
                          : getTagColor(category, theme),
                      selectedColor: context.theme.chipTheme.selectedColor,
                      selected: isSelected,
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
