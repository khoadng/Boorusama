// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../configs/ref.dart';
import '../../../../search/search/routes.dart';
import '../../../../tags/tag/tag.dart';
import '../../../../tags/tag/widgets.dart';
import '../../../post/post.dart';
import 'raw_tags_tile.dart';

class TagsTile extends StatelessWidget {
  const TagsTile({
    required this.post,
    required this.tags,
    super.key,
    this.onExpand,
    this.onCollapse,
    this.initialExpanded = false,
    this.tagColorBuilder,
    this.padding,
    this.initialCount,
  });

  final Post post;
  final void Function()? onExpand;
  final void Function()? onCollapse;
  final bool initialExpanded;
  final List<TagGroupItem>? tags;
  final Color? Function(Tag tag)? tagColorBuilder;
  final EdgeInsetsGeometry? padding;
  final int? initialCount;

  @override
  Widget build(BuildContext context) {
    final count = initialCount ?? post.tags.length;

    return RawTagsTile(
      title: RawTagsTileTitle(
        post: post,
        count: count,
      ),
      initiallyExpanded: initialExpanded,
      onExpansionChanged: (value) =>
          value ? onExpand?.call() : onCollapse?.call(),
      children: [
        PostTagList(
          padding: padding,
          tags: tags,
          itemBuilder: (context, tag) => GeneralTagContextMenu(
            tag: tag.rawName,
            child: Consumer(
              builder: (_, ref, __) => PostTagListChip(
                tag: tag,
                auth: ref.watchConfigAuth,
                onTap: () => goToSearchPage(context, tag: tag.rawName),
                color: tagColorBuilder != null ? tagColorBuilder!(tag) : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
