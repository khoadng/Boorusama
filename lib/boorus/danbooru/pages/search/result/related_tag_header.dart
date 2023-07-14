// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/utils.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'related_tag_chip.dart';
import 'view_more_tag_button.dart';

class RelatedTagHeader extends StatefulWidget {
  const RelatedTagHeader({
    super.key,
    required this.relatedTag,
    required this.onSelected,
  });

  final RelatedTag relatedTag;
  final void Function(RelatedTagItem item) onSelected;

  @override
  State<RelatedTagHeader> createState() => _RelatedTagHeaderState();
}

class _RelatedTagHeaderState extends State<RelatedTagHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      height: 50,
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: [
          ...widget.relatedTag.tags.take(15).map((item) => _RelatedTagChip(
                relatedTag: item,
                onPressed: () => widget.onSelected(item),
              )),
          const VerticalDivider(
            indent: 12,
            endIndent: 12,
            thickness: 2,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 10,
            ),
            child: ViewMoreTagButton(
              relatedTag: widget.relatedTag,
              onSelected: widget.onSelected,
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedTagChip extends ConsumerWidget {
  const _RelatedTagChip({
    required this.relatedTag,
    required this.onPressed,
  });

  final RelatedTagItem relatedTag;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return RelatedTagButton(
      theme: theme,
      backgroundColor: getTagColor(relatedTag.category, theme),
      onPressed: onPressed,
      label: Text(
        relatedTag.tag.removeUnderscoreWithSpace(),
        overflow: TextOverflow.fade,
        maxLines: 1,
        softWrap: false,
      ),
    );
  }
}
