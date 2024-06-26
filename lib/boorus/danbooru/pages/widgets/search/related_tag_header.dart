// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/string.dart';
import 'related_tag_chip.dart';

class RelatedTagHeader extends ConsumerStatefulWidget {
  const RelatedTagHeader({
    super.key,
    required this.relatedTag,
    required this.onAdded,
    required this.onNegated,
    this.backgroundColor,
  });

  final RelatedTag relatedTag;
  final void Function(RelatedTagItem item) onAdded;
  final void Function(RelatedTagItem item) onNegated;
  final Color? backgroundColor;

  @override
  ConsumerState<RelatedTagHeader> createState() => _RelatedTagHeaderState();
}

class _RelatedTagHeaderState extends ConsumerState<RelatedTagHeader> {
  @override
  Widget build(BuildContext context) {
    final data = [
      ...widget.relatedTag.tags.take(15),
      null,
      '',
    ];

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      color: widget.backgroundColor,
      height: 28,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        itemBuilder: (context, index) => switch (data[index]) {
          RelatedTagItem item => RelatedTagButton(
              backgroundColor: ref.watch(tagColorProvider(item.category.name)),
              onAdd: () => widget.onAdded(item),
              onRemove: () => widget.onNegated(item),
              label: Text(
                item.tag.replaceUnderscoreWithSpace(),
                overflow: TextOverflow.fade,
                maxLines: 1,
                softWrap: false,
              ),
            ),
          String _ => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
              ),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  foregroundColor: context.iconTheme.color,
                  backgroundColor: context.colorScheme.surfaceContainerHighest,
                  side: BorderSide(
                    color: context.theme.hintColor,
                  ),
                ),
                onPressed: () => goToRelatedTagsPage(
                  context,
                  relatedTag: widget.relatedTag,
                  onAdded: widget.onAdded,
                  onNegated: widget.onNegated,
                ),
                child: const Text('tag.related.more').tr(),
              ),
            ),
          null => const VerticalDivider(
              thickness: 2,
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}
