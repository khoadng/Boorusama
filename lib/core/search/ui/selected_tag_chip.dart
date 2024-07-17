// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/string.dart';

// Project imports:

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
    final hasAny = hasMeta || hasOperator;

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (c) {
            final controller = TextEditingController()
              ..text = tagSearchItem.toString();
            return SelectedTagEditDialog(
              controller: controller,
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
          if (hasOperator)
            Chip(
              visualDensity: const ShrinkVisualDensity(),
              backgroundColor: context.colorScheme.tertiary,
              labelPadding: const EdgeInsets.symmetric(horizontal: 1),
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
                ),
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
                tagSearchItem.tag.replaceUnderscoreWithSpace(),
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

class SelectedTagEditDialog extends StatelessWidget {
  const SelectedTagEditDialog({
    super.key,
    required this.controller,
    required this.onUpdated,
  });

  final TextEditingController controller;
  final void Function(String tag)? onUpdated;

  void _submit(BuildContext context) {
    onUpdated?.call(controller.text);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          child: SizedBox.shrink(),
        ),
        Material(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: BooruTextField(
              autocorrect: false,
              autofocus: true,
              controller: controller,
              onSubmitted: (_) => _submit(context),
              decoration: InputDecoration(
                suffixIcon: TextButton(
                  child: const Text('generic.action.ok').tr(),
                  onPressed: () => _submit(context),
                ),
              ),
            ),
          ),
        ),
        const Expanded(
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}
