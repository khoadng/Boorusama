// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../tags/tag/colors.dart';
import '../../../../utils/flutter_utils.dart';
import '../../../queries/filter_operator.dart';
import '../../../selected_tags/tag_search_item.dart';
import '../pages/selected_tag_edit_dialog.dart';

class SelectedTagChip extends StatelessWidget {
  const SelectedTagChip({
    required this.tagSearchItem,
    super.key,
    this.onDeleted,
    this.onUpdated,
  });

  final TagSearchItem tagSearchItem;
  final VoidCallback? onDeleted;
  final void Function(String tag)? onUpdated;

  @override
  Widget build(BuildContext context) {
    final hasOperator = tagSearchItem.operator != FilterOperator.none;
    final hasMeta = tagSearchItem.metatag != null;
    final isRaw = tagSearchItem.isRaw;

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (c) {
            return SelectedTagEditDialog(
              tag: tagSearchItem,
              onUpdated: (tag) {
                if (tag.isNotEmpty) {
                  onUpdated?.call(tag);
                } else {
                  onDeleted?.call();
                }
              },
            );
          },
        );
      },
      child: Chip(
        visualDensity: const ShrinkVisualDensity(),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        deleteIcon: Icon(
          Symbols.close,
          color: Theme.of(context).colorScheme.error,
          size: 18,
          weight: 600,
        ),
        onDeleted: () => onDeleted?.call(),
        labelPadding: const EdgeInsets.symmetric(horizontal: 2),
        label: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
            children: [
              if (isRaw) ...[
                TextSpan(
                  text: 'RAW   ',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? TagColors.dark().character
                        : TagColors.light().character,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                    fontSize: 13,
                  ),
                ),
              ] else if (hasOperator)
                TextSpan(
                  text: switch (tagSearchItem.operator) {
                    FilterOperator.none => '',
                    FilterOperator.not => '—',
                    FilterOperator.or => '⁓',
                  },
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? TagColors.dark().copyright
                        : TagColors.light().copyright,
                  ),
                ),
              if (hasMeta)
                TextSpan(
                  text: '${tagSearchItem.metatag}: ',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? TagColors.dark().meta
                        : TagColors.light().meta,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    fontSize: 15,
                  ),
                ),
              TextSpan(
                text: isRaw
                    ? tagSearchItem.tag
                    : tagSearchItem.tag.replaceAll('_', ' '),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
              const TextSpan(
                text: ' ',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
