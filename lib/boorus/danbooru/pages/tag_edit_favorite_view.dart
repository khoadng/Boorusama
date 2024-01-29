// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/string.dart';

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
  var selectedLabel = '';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FavoriteTagsFilterScope(
        initialValue: selectedLabel,
        builder: (_, tags, labels, selected) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              child: Row(
                children: [
                  TagLabelsDropDownButton(
                    tagLabels: labels,
                    selectedLabel: selected,
                    alignment: AlignmentDirectional.centerStart,
                    onChanged: (value) {
                      setState(() {
                        selectedLabel = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: tags.isNotEmpty
                  ? Wrap(
                      spacing: 4,
                      children: tags.map((tag) {
                        final selected = widget.isSelected(tag.name);

                        return FilterChip(
                          side: selected
                              ? BorderSide(
                                  color: context.theme.hintColor,
                                  width: 0.5,
                                )
                              : null,
                          selected: selected,
                          showCheckmark: false,
                          visualDensity: VisualDensity.compact,
                          selectedColor: context.colorScheme.primary,
                          backgroundColor: context.colorScheme.background,
                          onSelected: (value) => value
                              ? widget.onAdded(tag.name)
                              : widget.onRemoved(tag.name),
                          label: Text(
                            tag.name.replaceUnderscoreWithSpace(),
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
