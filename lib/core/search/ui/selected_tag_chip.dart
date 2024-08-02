// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/string.dart';
import 'selected_tag_edit_dialog.dart';

class SelectedTagChip extends StatelessWidget {
  const SelectedTagChip({
    super.key,
    required this.tagSearchItem,
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
    final hasAny = hasMeta || hasOperator || isRaw;

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: true,
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isRaw)
            Chip(
              visualDensity: const ShrinkVisualDensity(),
              backgroundColor: context.colorScheme.errorContainer,
              labelPadding: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              label: Text(
                'RAW',
                style: TextStyle(
                  color: context.colorScheme.onErrorContainer,
                  letterSpacing: -1,
                ),
              ),
            )
          else if (hasOperator)
            Chip(
              visualDensity: const ShrinkVisualDensity(),
              backgroundColor: context.colorScheme.tertiary,
              labelPadding: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              label: Text(
                filterOperatorToStringCharacter(tagSearchItem.operator),
                style: TextStyle(
                  color: context.colorScheme.onTertiary,
                  letterSpacing: -1,
                ),
              ),
            ),
          if (hasMeta)
            Chip(
              visualDensity: const ShrinkVisualDensity(),
              backgroundColor: context.colorScheme.secondary,
              labelPadding: EdgeInsets.zero,
              shape: _getOutlineBorderForMetaChip(hasOperator),
              label: Text(
                tagSearchItem.metatag!,
                style: TextStyle(
                  color: context.colorScheme.onSecondary,
                ),
              ),
            ),
          Chip(
            visualDensity: const ShrinkVisualDensity(),
            backgroundColor: context.colorScheme.secondaryContainer,
            shape: hasAny
                ? const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  )
                : null,
            deleteIcon: Icon(
              Symbols.close,
              color: context.colorScheme.error,
              size: 18,
              weight: 600,
            ),
            onDeleted: () => onDeleted?.call(),
            labelPadding: const EdgeInsets.symmetric(horizontal: 2),
            label: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: context.screenWidth * 0.85,
              ),
              child: Text(
                tagSearchItem.isRaw
                    ? tagSearchItem.tag
                    : tagSearchItem.tag.replaceUnderscoreWithSpace(),
                overflow: TextOverflow.fade,
              ),
            ),
          ),
        ],
      ),
    );
  }

  OutlinedBorder? _getOutlineBorderForMetaChip(bool hasOperator) {
    return !hasOperator
        ? const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
          )
        : const RoundedRectangleBorder();
  }
}
