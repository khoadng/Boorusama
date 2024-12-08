// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/related_tags/related_tag_chip.dart';
import 'package:boorusama/core/tags/tag/providers.dart';
import 'package:boorusama/core/theme.dart';
import 'danbooru_related_tag.dart';

class RelatedTagHeader extends ConsumerStatefulWidget {
  const RelatedTagHeader({
    super.key,
    required this.relatedTag,
    required this.onAdded,
    required this.onNegated,
    this.backgroundColor,
  });

  final DanbooruRelatedTag relatedTag;
  final void Function(DanbooruRelatedTagItem item) onAdded;
  final void Function(DanbooruRelatedTagItem item) onNegated;
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
          final DanbooruRelatedTagItem item => RelatedTagButton(
              backgroundColor: ref.watch(tagColorProvider(item.category.name)),
              onAdd: () => widget.onAdded(item),
              onRemove: () => widget.onNegated(item),
              label: Text(
                item.tag.replaceAll('_', ' '),
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
                  foregroundColor: Theme.of(context).iconTheme.color,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.hintColor,
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
