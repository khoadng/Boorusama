// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class TagsTile extends ConsumerWidget {
  const TagsTile({
    super.key,
    required this.post,
    this.onExpand,
    this.onCollapse,
    this.onTagTap,
    this.initialExpanded = false,
    required this.tags,
  });

  final Post post;
  final void Function()? onExpand;
  final void Function()? onCollapse;
  final void Function(Tag tag)? onTagTap;
  final bool initialExpanded;
  final List<TagGroupItem>? tags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Theme(
      data: context.theme.copyWith(
        listTileTheme: context.theme.listTileTheme.copyWith(
          visualDensity: VisualDensity.compact,
        ),
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        initiallyExpanded: initialExpanded,
        title: Text('${post.tags.length} tags'),
        controlAffinity: ListTileControlAffinity.leading,
        onExpansionChanged: (value) =>
            value ? onExpand?.call() : onCollapse?.call(),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: PostTagList(
              tags: tags,
              itemBuilder: (context, tag) => GeneralTagContextMenu(
                tag: tag.rawName,
                child: PostTagListChip(
                  tag: tag,
                  onTap: () => onTagTap?.call(tag),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
