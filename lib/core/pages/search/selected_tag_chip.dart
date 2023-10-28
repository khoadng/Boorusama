// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/core/feats/search/search.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/string.dart';

// Project imports:

class SelectedTagChip extends StatelessWidget {
  const SelectedTagChip({
    super.key,
    required this.tagSearchItem,
    this.onDeleted,
  });

  final TagSearchItem tagSearchItem;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    final hasOperator = tagSearchItem.operator != FilterOperator.none;
    final hasMeta = tagSearchItem.metatag != null;
    final hasAny = hasMeta || hasOperator;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasOperator)
          Chip(
            visualDensity: const ShrinkVisualDensity(),
            backgroundColor: Colors.purple,
            labelPadding: const EdgeInsets.symmetric(horizontal: 1),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            label: Text(
              filterOperatorToStringCharacter(tagSearchItem.operator),
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        if (hasMeta)
          Chip(
            visualDensity: const ShrinkVisualDensity(),
            backgroundColor: context.colorScheme.secondary,
            labelPadding: const EdgeInsets.symmetric(horizontal: 1),
            shape: _getOutlineBorderForMetaChip(hasOperator),
            label: Text(
              tagSearchItem.metatag!,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        Chip(
          visualDensity: const ShrinkVisualDensity(),
          backgroundColor: Colors.grey[800],
          shape: hasAny
              ? const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                )
              : null,
          deleteIcon: const Icon(
            FontAwesomeIcons.xmark,
            color: Colors.red,
            size: 15,
          ),
          onDeleted: () => onDeleted?.call(),
          labelPadding: const EdgeInsets.symmetric(horizontal: 2),
          label: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.screenWidth * 0.85,
            ),
            child: Text(
              tagSearchItem.tag.replaceUnderscoreWithSpace(),
              overflow: TextOverflow.fade,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ],
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
