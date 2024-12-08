// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/cache/providers.dart';
import 'package:boorusama/core/favorited_tags/favorited_tags.dart';
import 'package:boorusama/foundation/platform.dart';

const kTagEditFavoriteViewSelectedLabelKey =
    'tag_edit_favorite_view_selected_label';

class TagEditFavoriteView extends ConsumerStatefulWidget {
  const TagEditFavoriteView({
    super.key,
    required this.onRemoved,
    required this.onAdded,
    required this.isSelected,
  });

  final void Function(String tag) onRemoved;
  final void Function(String tag) onAdded;
  final bool Function(String tag) isSelected;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TagEditFavoriteViewState();
}

class _TagEditFavoriteViewState extends ConsumerState<TagEditFavoriteView> {
  @override
  Widget build(BuildContext context) {
    final selectedLabel =
        ref.watch(miscDataProvider(kTagEditFavoriteViewSelectedLabelKey));

    return SingleChildScrollView(
      child: FavoriteTagsFilterScope(
        initialValue: selectedLabel,
        sortType: FavoriteTagsSortType.nameAZ,
        builder: (_, tags, labels, selected) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              child: FavoriteTagLabelSelectorField(
                selected: selected,
                labels: labels,
                onSelect: (value) {
                  ref
                      .read(
                        miscDataProvider(kTagEditFavoriteViewSelectedLabelKey)
                            .notifier,
                      )
                      .put(value);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: tags.isNotEmpty
                  ? Wrap(
                      spacing: 4,
                      runSpacing: isDesktopPlatform() ? 4 : 0,
                      children: tags.map((tag) {
                        final selected = widget.isSelected(tag.name);

                        return FilterChip(
                          selected: selected,
                          showCheckmark: false,
                          visualDensity: VisualDensity.compact,
                          selectedColor: Theme.of(context).colorScheme.primary,
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          onSelected: (value) => value
                              ? widget.onAdded(tag.name)
                              : widget.onRemoved(tag.name),
                          label: Text(
                            tag.name.replaceAll('_', ' '),
                            style: TextStyle(
                              color: selected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  : const Center(
                      child: Text(
                        'No favorites',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
