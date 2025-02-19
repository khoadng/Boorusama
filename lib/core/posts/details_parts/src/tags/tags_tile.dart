// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/display/media_query_utils.dart';
import '../../../../tags/tag/tag.dart';
import '../../../../tags/tag/widgets.dart';
import '../../../post/post.dart';
import '../_internal/details_widget_frame.dart';

class TagsTile extends ConsumerWidget {
  const TagsTile({
    required this.post,
    required this.tags,
    super.key,
    this.onExpand,
    this.onCollapse,
    this.onTagTap,
    this.initialExpanded = false,
    this.tagColorBuilder,
    this.padding,
    this.initialCount,
  });

  final Post post;
  final void Function()? onExpand;
  final void Function()? onCollapse;
  final void Function(Tag tag)? onTagTap;
  final bool initialExpanded;
  final List<TagGroupItem>? tags;
  final Color? Function(Tag tag)? tagColorBuilder;
  final EdgeInsetsGeometry? padding;
  final int? initialCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = initialCount ?? post.tags.length;

    return DetailsWidgetSeparator(
      child: Theme(
        data: Theme.of(context).copyWith(
          listTileTheme: Theme.of(context).listTileTheme.copyWith(
                visualDensity: VisualDensity.compact,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
              ),
          dividerColor: Colors.transparent,
        ),
        child: RemoveLeftPaddingOnLargeScreen(
          child: DetailsWidgetSeparator(
            child: ExpansionTile(
              initiallyExpanded: initialExpanded,
              title: Text('$count tags'),
              controlAffinity: ListTileControlAffinity.trailing,
              onExpansionChanged: (value) =>
                  value ? onExpand?.call() : onCollapse?.call(),
              children: [
                Padding(
                  padding:
                      padding ?? const EdgeInsets.symmetric(horizontal: 12),
                  child: PostTagList(
                    tags: tags,
                    itemBuilder: (context, tag) => GeneralTagContextMenu(
                      tag: tag.rawName,
                      child: PostTagListChip(
                        tag: tag,
                        onTap: () => onTagTap?.call(tag),
                        color: tagColorBuilder != null
                            ? tagColorBuilder!(tag)
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
